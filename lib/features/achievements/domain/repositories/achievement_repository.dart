import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/achievement_entities.dart';

/// Repositorio de logros
abstract class AchievementRepository {
  /// Obtener todos los logros disponibles
  Future<Either<Failure, List<Achievement>>> getAllAchievements();

  /// Obtener el resumen de logros del usuario
  Future<Either<Failure, AchievementsSummary>> getUserAchievementsSummary();

  /// Obtener logros desbloqueados por el usuario
  Future<Either<Failure, List<UnlockedAchievement>>> getUnlockedAchievements();

  /// Verificar y desbloquear logros basados en el progreso actual
  Future<Either<Failure, List<UnlockedAchievement>>> checkAndUnlockAchievements({
    required int lessonsCompleted,
    required int currentStreak,
    required int perfectScores,
    required int modulesCompleted,
  });

  /// Desbloquear un logro específico
  Future<Either<Failure, UnlockedAchievement>> unlockAchievement(String achievementId);

  /// Obtener el progreso hacia todos los logros
  Future<Either<Failure, List<AchievementProgress>>> getAchievementsProgress();
}
