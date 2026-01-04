import '../../domain/entities/progress_entities.dart';

class LessonProgressModel extends LessonProgress {
  const LessonProgressModel({
    required super.id,
    required super.userId,
    required super.lessonId,
    super.lessonTitle,
    required super.completed,
    super.completedAt,
    required super.accuracy,
    required super.totalAttempts,
    required super.correctAttempts,
    required super.timeSpent,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String?,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      correctAttempts: json['correctAttempts'] as int? ?? 0,
      timeSpent: json['timeSpent'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class UnlockedLevelModel extends UnlockedLevel {
  const UnlockedLevelModel({
    required super.id,
    required super.userId,
    required super.levelSectionId,
    super.levelName,
    required super.unlockedAt,
    required super.daysUnlocked,
    required super.isRecentlyUnlocked,
  });

  factory UnlockedLevelModel.fromJson(Map<String, dynamic> json) {
    return UnlockedLevelModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      levelSectionId: json['levelSectionId'] as String,
      levelName: json['levelName'] as String?,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      daysUnlocked: json['daysUnlocked'] as int? ?? 0,
      isRecentlyUnlocked: json['isRecentlyUnlocked'] as bool? ?? false,
    );
  }
}

class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.userId,
    required super.totalLessonsStarted,
    required super.totalLessonsCompleted,
    required super.averageAccuracy,
    required super.totalTimeSpent,
    required super.unlockedLevels,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId'] as String,
      totalLessonsStarted: json['totalLessonsStarted'] as int? ?? 0,
      totalLessonsCompleted: json['totalLessonsCompleted'] as int? ?? 0,
      averageAccuracy: (json['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      totalTimeSpent: json['totalTimeSpent'] as int? ?? 0,
      unlockedLevels: json['unlockedLevels'] as int? ?? 0,
    );
  }
}

class CompleteLessonResultModel extends CompleteLessonResult {
  const CompleteLessonResultModel({
    required LessonProgressModel progress,
    UnlockedLevelModel? levelUnlocked,
  }) : super(progress: progress, levelUnlocked: levelUnlocked);

  factory CompleteLessonResultModel.fromJson(Map<String, dynamic> json) {
    UnlockedLevelModel? levelUnlocked;
    if (json['levelUnlocked'] != null) {
      levelUnlocked = UnlockedLevelModel.fromJson(
        json['levelUnlocked'] as Map<String, dynamic>,
      );
    }

    return CompleteLessonResultModel(
      progress: LessonProgressModel.fromJson(
        json['progress'] as Map<String, dynamic>,
      ),
      levelUnlocked: levelUnlocked,
    );
  }
}

class DailyActivityModel extends DailyActivity {
  const DailyActivityModel({
    required super.date,
    required super.lessonsCompleted,
    required super.timeSpent,
    required super.accuracy,
  });

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
      date: DateTime.parse(json['date'] as String),
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      timeSpent: json['timeSpent'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StreakModel extends Streak {
  const StreakModel({
    required super.currentStreak,
    required super.longestStreak,
    super.lastActivityDate,
    required super.isActiveToday,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      isActiveToday: json['isActiveToday'] as bool? ?? false,
    );
  }

  /// Calcular racha desde lista de progreso
  factory StreakModel.fromProgressList(List<LessonProgress> progressList) {
    if (progressList.isEmpty) {
      return const StreakModel(
        currentStreak: 0,
        longestStreak: 0,
        isActiveToday: false,
      );
    }

    // Ordenar por fecha de completado
    final completed = progressList
        .where((p) => p.completed && p.completedAt != null)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    if (completed.isEmpty) {
      return const StreakModel(
        currentStreak: 0,
        longestStreak: 0,
        isActiveToday: false,
      );
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Obtener días únicos con actividad
    final uniqueDays = <DateTime>{};
    for (final p in completed) {
      final date = p.completedAt!;
      uniqueDays.add(DateTime(date.year, date.month, date.day));
    }

    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));
    
    // Calcular racha actual
    int currentStreak = 0;
    DateTime checkDate = todayDate;
    
    // Verificar si hay actividad hoy o ayer
    final isActiveToday = sortedDays.isNotEmpty &&
        sortedDays.first.isAtSameMomentAs(todayDate);
    
    if (!isActiveToday && sortedDays.isNotEmpty) {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      if (!sortedDays.first.isAtSameMomentAs(yesterday)) {
        // No hay actividad ayer ni hoy, racha = 0
        return StreakModel(
          currentStreak: 0,
          longestStreak: _calculateLongestStreak(sortedDays),
          lastActivityDate: sortedDays.first,
          isActiveToday: false,
        );
      }
      checkDate = yesterday;
    }

    // Contar días consecutivos
    for (final day in sortedDays) {
      if (day.isAtSameMomentAs(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDate)) {
        break;
      }
    }

    return StreakModel(
      currentStreak: currentStreak,
      longestStreak: _calculateLongestStreak(sortedDays),
      lastActivityDate: sortedDays.first,
      isActiveToday: isActiveToday,
    );
  }

  static int _calculateLongestStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < sortedDays.length; i++) {
      final diff = sortedDays[i - 1].difference(sortedDays[i]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }

    return longest;
  }
}
