import 'package:dartz/dartz.dart';

import '../../../../core/cache/cache_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/progress_entities.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/progress_models.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource remoteDataSource;
  final ProgressLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProgressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, LessonProgress>> recordAttempt(
    RecordAttemptParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      // Guardar intento offline para sincronizar después
      await localDataSource.saveOfflineAttempt(params.toJson());
      
      // Retornar un progreso temporal
      return Right(LessonProgress(
        id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        userId: '',
        lessonId: params.lessonId,
        completed: false,
        accuracy: params.correct ? 100 : 0,
        totalAttempts: 1,
        correctAttempts: params.correct ? 1 : 0,
        timeSpent: params.timeSpent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    try {
      final result = await remoteDataSource.recordAttempt(params);
      return Right(result);
    } on ServerException catch (e) {
      // Si falla, guardar offline
      await localDataSource.saveOfflineAttempt(params.toJson());
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      await localDataSource.saveOfflineAttempt(params.toJson());
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompleteLessonResult>> completeLesson(
    CompleteLessonParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        message: 'Necesitas conexión para completar una lección',
      ));
    }

    try {
      final result = await remoteDataSource.completeLesson(params);
      // Invalidar caché después de completar
      await localDataSource.clearProgressCache();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LessonProgress>>> getUserProgress({
    String? lessonId,
  }) async {
    final cached = localDataSource.getCachedUserProgress();

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUserProgress(lessonId: lessonId);
        
        // Solo cachear si es la lista completa
        if (lessonId == null) {
          await localDataSource.cacheUserProgress(result);
        }
        
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null && lessonId == null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null && lessonId == null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    // Sin conexión
    if (cached != null && lessonId == null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, UserStats>> getUserStats() async {
    final cached = localDataSource.getCachedUserStats();

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUserStats();
        await localDataSource.cacheUserStats(result);
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, Streak>> getStreak() async {
    final cached = localDataSource.getCachedStreak();

    // Intentar calcular desde progreso
    final progressResult = await getUserProgress();

    return progressResult.fold(
      (failure) {
        // Si falla pero tenemos caché de streak, usar eso
        if (cached != null) return Right(cached);
        return Left(failure);
      },
      (progressList) {
        final streak = StreakModel.fromProgressList(progressList);
        // Cachear el streak calculado
        localDataSource.cacheStreak(streak);
        return Right(streak);
      },
    );
  }

  @override
  Future<Either<Failure, List<DailyActivity>>> getDailyActivity(int days) async {
    final cached = localDataSource.getCachedDailyActivity();

    // Obtener progreso y agrupar por día
    final progressResult = await getUserProgress();

    return progressResult.fold(
      (failure) {
        if (cached != null) return Right(cached);
        return Left(failure);
      },
      (progressList) {
        final dailyMap = <String, DailyActivityModel>{};
        final today = DateTime.now();

        // Inicializar últimos N días con valores en 0
        for (int i = 0; i < days; i++) {
          final date = today.subtract(Duration(days: i));
          final key = '${date.year}-${date.month}-${date.day}';
          dailyMap[key] = DailyActivityModel(
            date: DateTime(date.year, date.month, date.day),
            lessonsCompleted: 0,
            timeSpent: 0,
            accuracy: 0,
          );
        }

        // Agrupar progreso por día
        for (final progress in progressList) {
          if (progress.completedAt != null) {
            final date = progress.completedAt!;
            final key = '${date.year}-${date.month}-${date.day}';

            if (dailyMap.containsKey(key)) {
              final existing = dailyMap[key]!;
              final completedCount = existing.lessonsCompleted + (progress.completed ? 1 : 0);
              final totalTime = existing.timeSpent + progress.timeSpent;
              final avgAccuracy = completedCount > 0
                  ? ((existing.accuracy * existing.lessonsCompleted) + progress.accuracy) /
                      completedCount
                  : 0.0;

              dailyMap[key] = DailyActivityModel(
                date: existing.date,
                lessonsCompleted: completedCount,
                timeSpent: totalTime,
                accuracy: avgAccuracy,
              );
            }
          }
        }

        // Convertir a lista ordenada por fecha
        final result = dailyMap.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        // Cachear resultado
        localDataSource.cacheDailyActivity(result);

        return Right(result);
      },
    );
  }

  /// Sincronizar intentos guardados offline
  Future<void> syncOfflineAttempts() async {
    if (!await networkInfo.isConnected) return;

    final offlineAttempts = localDataSource.getOfflineAttempts();
    if (offlineAttempts.isEmpty) return;

    for (final attemptData in offlineAttempts) {
      try {
        final params = RecordAttemptParams(
          lessonId: attemptData['lessonId'] as String,
          activityId: attemptData['activityId'] as String,
          correct: attemptData['correct'] as bool,
          timeSpent: attemptData['timeSpent'] as int,
        );
        await remoteDataSource.recordAttempt(params);
      } catch (e) {
        // Si falla, mantener en la cola
        continue;
      }
    }

    // Limpiar intentos sincronizados
    await localDataSource.clearOfflineAttempts();
  }
}
