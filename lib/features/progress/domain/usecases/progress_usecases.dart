import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/progress_entities.dart';
import '../repositories/progress_repository.dart';

/// Registrar intento de actividad
class RecordAttemptUseCase {
  final ProgressRepository repository;

  RecordAttemptUseCase(this.repository);

  Future<Either<Failure, LessonProgress>> call(RecordAttemptParams params) {
    return repository.recordAttempt(params);
  }
}

/// Completar lección
class CompleteLessonUseCase {
  final ProgressRepository repository;

  CompleteLessonUseCase(this.repository);

  Future<Either<Failure, CompleteLessonResult>> call(CompleteLessonParams params) {
    return repository.completeLesson(params);
  }
}

/// Obtener progreso del usuario
class GetUserProgressUseCase {
  final ProgressRepository repository;

  GetUserProgressUseCase(this.repository);

  Future<Either<Failure, List<LessonProgress>>> call({String? lessonId}) {
    return repository.getUserProgress(lessonId: lessonId);
  }
}

/// Obtener estadísticas del usuario
class GetUserStatsUseCase {
  final ProgressRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<Either<Failure, UserStats>> call() {
    return repository.getUserStats();
  }
}

/// Obtener racha de días
class GetStreakUseCase {
  final ProgressRepository repository;

  GetStreakUseCase(this.repository);

  Future<Either<Failure, Streak>> call() {
    return repository.getStreak();
  }
}

/// Obtener actividad diaria
class GetDailyActivityUseCase {
  final ProgressRepository repository;

  GetDailyActivityUseCase(this.repository);

  Future<Either<Failure, List<DailyActivity>>> call(int days) {
    return repository.getDailyActivity(days);
  }
}
