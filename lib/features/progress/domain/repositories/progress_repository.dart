import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/progress_entities.dart';

/// Repositorio de progreso del usuario
abstract class ProgressRepository {
  /// Registrar un intento de actividad
  Future<Either<Failure, LessonProgress>> recordAttempt(RecordAttemptParams params);

  /// Completar una lección
  Future<Either<Failure, CompleteLessonResult>> completeLesson(CompleteLessonParams params);

  /// Obtener progreso del usuario (opcionalmente filtrado por lección)
  Future<Either<Failure, List<LessonProgress>>> getUserProgress({String? lessonId});

  /// Obtener estadísticas del usuario
  Future<Either<Failure, UserStats>> getUserStats();

  /// Obtener racha de días (calculado localmente o desde API)
  Future<Either<Failure, Streak>> getStreak();

  /// Obtener actividad de los últimos N días (para gráficos)
  Future<Either<Failure, List<DailyActivity>>> getDailyActivity(int days);
}
