import 'package:equatable/equatable.dart';

/// Progreso de una lección
class LessonProgress extends Equatable {
  final String id;
  final String userId;
  final String lessonId;
  final String? lessonTitle;
  final bool completed;
  final DateTime? completedAt;
  final double accuracy;
  final int totalAttempts;
  final int correctAttempts;
  final int timeSpent; // en segundos
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    this.lessonTitle,
    required this.completed,
    this.completedAt,
    required this.accuracy,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.timeSpent,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tiempo formateado (ej: "5m 30s")
  String get timeSpentFormatted {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  List<Object?> get props => [id, lessonId, completed, accuracy];
}

/// Nivel desbloqueado
class UnlockedLevel extends Equatable {
  final String id;
  final String userId;
  final String levelSectionId;
  final String? levelName;
  final DateTime unlockedAt;
  final int daysUnlocked;
  final bool isRecentlyUnlocked;

  const UnlockedLevel({
    required this.id,
    required this.userId,
    required this.levelSectionId,
    this.levelName,
    required this.unlockedAt,
    required this.daysUnlocked,
    required this.isRecentlyUnlocked,
  });

  @override
  List<Object?> get props => [id, levelSectionId, unlockedAt];
}

/// Estadísticas generales del usuario
class UserStats extends Equatable {
  final String userId;
  final int totalLessonsStarted;
  final int totalLessonsCompleted;
  final double averageAccuracy;
  final int totalTimeSpent; // en segundos
  final int unlockedLevels;

  const UserStats({
    required this.userId,
    required this.totalLessonsStarted,
    required this.totalLessonsCompleted,
    required this.averageAccuracy,
    required this.totalTimeSpent,
    required this.unlockedLevels,
  });

  /// Tiempo total formateado
  String get totalTimeFormatted {
    final hours = totalTimeSpent ~/ 3600;
    final minutes = (totalTimeSpent % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Porcentaje de lecciones completadas
  double get completionRate {
    if (totalLessonsStarted == 0) return 0;
    return (totalLessonsCompleted / totalLessonsStarted) * 100;
  }

  @override
  List<Object?> get props => [
        userId,
        totalLessonsCompleted,
        averageAccuracy,
        totalTimeSpent,
      ];
}

/// Respuesta al completar una lección
class CompleteLessonResult extends Equatable {
  final LessonProgress progress;
  final UnlockedLevel? levelUnlocked;

  const CompleteLessonResult({
    required this.progress,
    this.levelUnlocked,
  });

  bool get hasUnlockedNewLevel => levelUnlocked != null;

  @override
  List<Object?> get props => [progress, levelUnlocked];
}

/// Datos para registrar un intento
class RecordAttemptParams {
  final String lessonId;
  final String activityId;
  final bool correct;
  final int timeSpent;

  const RecordAttemptParams({
    required this.lessonId,
    required this.activityId,
    required this.correct,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'activityId': activityId,
        'correct': correct,
        'timeSpent': timeSpent,
      };
}

/// Datos para completar una lección
class CompleteLessonParams {
  final String lessonId;

  const CompleteLessonParams({required this.lessonId});

  Map<String, dynamic> toJson() => {'lessonId': lessonId};
}

/// Resumen diario de actividad (para gráficos)
class DailyActivity extends Equatable {
  final DateTime date;
  final int lessonsCompleted;
  final int timeSpent;
  final double accuracy;

  const DailyActivity({
    required this.date,
    required this.lessonsCompleted,
    required this.timeSpent,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [date, lessonsCompleted];
}

/// Racha de días consecutivos
class Streak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final bool isActiveToday;

  const Streak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.isActiveToday,
  });

  @override
  List<Object?> get props => [currentStreak, longestStreak, isActiveToday];
}
