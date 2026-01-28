import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/achievement_entities.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/achievement_local_datasource.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementLocalDataSource localDataSource;

  AchievementRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Achievement>>> getAllAchievements() async {
    try {
      return Right(AchievementDefinitions.all);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener logros: $e'));
    }
  }

  @override
  Future<Either<Failure, AchievementsSummary>> getUserAchievementsSummary() async {
    try {
      final allAchievements = AchievementDefinitions.all;
      final unlocked = localDataSource.getCachedUnlockedAchievements() ?? [];
      final totalPoints = localDataSource.getTotalPoints();

      final progressList = <AchievementProgress>[];

      for (final achievement in allAchievements) {
        final isUnlocked = unlocked.any((u) => u.achievementId == achievement.id);
        final unlockedAchievement = isUnlocked
            ? unlocked.firstWhere((u) => u.achievementId == achievement.id)
            : null;

        progressList.add(AchievementProgress(
          achievementId: achievement.id,
          achievement: achievement,
          currentProgress: isUnlocked ? achievement.requiredValue : 0,
          requiredProgress: achievement.requiredValue,
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAchievement?.unlockedAt,
        ));
      }

      return Right(AchievementsSummary(
        totalAchievements: allAchievements.length,
        unlockedCount: unlocked.length,
        totalPoints: totalPoints,
        achievements: progressList,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener resumen: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UnlockedAchievement>>> getUnlockedAchievements() async {
    try {
      final unlocked = localDataSource.getCachedUnlockedAchievements() ?? [];
      return Right(unlocked);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener logros desbloqueados: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UnlockedAchievement>>> checkAndUnlockAchievements({
    required int lessonsCompleted,
    required int currentStreak,
    required int perfectScores,
    required int modulesCompleted,
  }) async {
    try {
      final newlyUnlocked = <UnlockedAchievement>[];
      final allAchievements = AchievementDefinitions.all;

      for (final achievement in allAchievements) {
        // Verificar si ya está desbloqueado
        if (localDataSource.isAchievementUnlocked(achievement.id)) {
          continue;
        }

        bool shouldUnlock = false;

        switch (achievement.category) {
          case AchievementCategory.lessons:
            shouldUnlock = lessonsCompleted >= achievement.requiredValue;
            break;
          case AchievementCategory.streaks:
            shouldUnlock = currentStreak >= achievement.requiredValue;
            break;
          case AchievementCategory.perfectScores:
            shouldUnlock = perfectScores >= achievement.requiredValue;
            break;
          case AchievementCategory.modules:
            shouldUnlock = modulesCompleted >= achievement.requiredValue;
            break;
          case AchievementCategory.milestones:
            // Los hitos se manejan de forma especial
            if (achievement.id == 'first_activity') {
              shouldUnlock = lessonsCompleted >= 1;
            } else if (achievement.id == 'early_bird') {
              final now = DateTime.now();
              shouldUnlock = now.hour < 8;
            } else if (achievement.id == 'night_owl') {
              final now = DateTime.now();
              shouldUnlock = now.hour >= 22;
            }
            break;
        }

        if (shouldUnlock) {
          final unlockResult = await unlockAchievement(achievement.id);
          unlockResult.fold(
            (_) {},
            (unlocked) => newlyUnlocked.add(unlocked),
          );
        }
      }

      return Right(newlyUnlocked);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al verificar logros: $e'));
    }
  }

  @override
  Future<Either<Failure, UnlockedAchievement>> unlockAchievement(String achievementId) async {
    try {
      // Verificar si ya está desbloqueado
      if (localDataSource.isAchievementUnlocked(achievementId)) {
        return const Left(ServerFailure(message: 'Logro ya desbloqueado'));
      }

      final achievement = AchievementDefinitions.getById(achievementId);
      if (achievement == null) {
        return const Left(ServerFailure(message: 'Logro no encontrado'));
      }

      final unlocked = UnlockedAchievement(
        id: 'unlock_${achievementId}_${DateTime.now().millisecondsSinceEpoch}',
        achievementId: achievementId,
        userId: 'current_user',
        unlockedAt: DateTime.now(),
        achievement: achievement,
      );

      await localDataSource.addUnlockedAchievement(unlocked);

      return Right(unlocked);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al desbloquear logro: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AchievementProgress>>> getAchievementsProgress() async {
    try {
      final summary = await getUserAchievementsSummary();
      return summary.fold(
        (failure) => Left(failure),
        (summary) => Right(summary.achievements),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener progreso: $e'));
    }
  }
}
