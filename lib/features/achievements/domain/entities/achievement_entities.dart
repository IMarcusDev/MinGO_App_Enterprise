import 'package:equatable/equatable.dart';

/// Categorías de logros
enum AchievementCategory {
  lessons('lessons', 'Lecciones'),
  streaks('streaks', 'Rachas'),
  perfectScores('perfect_scores', 'Puntuaciones Perfectas'),
  modules('modules', 'Módulos'),
  milestones('milestones', 'Hitos');

  final String value;
  final String displayName;

  const AchievementCategory(this.value, this.displayName);

  static AchievementCategory fromString(String value) {
    return AchievementCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => AchievementCategory.milestones,
    );
  }
}

/// Nivel del logro
enum AchievementTier {
  bronze('bronze', 'Bronce', '🥉'),
  silver('silver', 'Plata', '🥈'),
  gold('gold', 'Oro', '🥇'),
  platinum('platinum', 'Platino', '💎');

  final String value;
  final String displayName;
  final String emoji;

  const AchievementTier(this.value, this.displayName, this.emoji);

  static AchievementTier fromString(String value) {
    return AchievementTier.values.firstWhere(
      (t) => t.value == value,
      orElse: () => AchievementTier.bronze,
    );
  }
}

/// Definición de un logro
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final String icon;
  final int requiredValue;
  final int points;
  final AchievementTier tier;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.requiredValue,
    required this.points,
    required this.tier,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        icon,
        requiredValue,
        points,
        tier,
      ];
}

/// Logro desbloqueado por el usuario
class UnlockedAchievement extends Equatable {
  final String id;
  final String achievementId;
  final String userId;
  final DateTime unlockedAt;
  final Achievement achievement;

  const UnlockedAchievement({
    required this.id,
    required this.achievementId,
    required this.userId,
    required this.unlockedAt,
    required this.achievement,
  });

  @override
  List<Object?> get props => [id, achievementId, userId, unlockedAt, achievement];
}

/// Progreso hacia un logro
class AchievementProgress extends Equatable {
  final String achievementId;
  final Achievement achievement;
  final int currentProgress;
  final int requiredProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementProgress({
    required this.achievementId,
    required this.achievement,
    required this.currentProgress,
    required this.requiredProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double get percentComplete {
    if (requiredProgress == 0) return 0;
    return (currentProgress / requiredProgress).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        achievementId,
        achievement,
        currentProgress,
        requiredProgress,
        isUnlocked,
        unlockedAt,
      ];
}

/// Resumen de logros del usuario
class AchievementsSummary extends Equatable {
  final int totalAchievements;
  final int unlockedCount;
  final int totalPoints;
  final List<AchievementProgress> achievements;

  const AchievementsSummary({
    required this.totalAchievements,
    required this.unlockedCount,
    required this.totalPoints,
    required this.achievements,
  });

  double get completionPercentage {
    if (totalAchievements == 0) return 0;
    return unlockedCount / totalAchievements;
  }

  @override
  List<Object?> get props => [
        totalAchievements,
        unlockedCount,
        totalPoints,
        achievements,
      ];
}

/// Lista predefinida de logros del sistema
class AchievementDefinitions {
  static List<Achievement> get all => [
    // === LECCIONES ===
    const Achievement(
      id: 'first_lesson',
      title: 'Primera Lección',
      description: 'Completa tu primera lección',
      category: AchievementCategory.lessons,
      icon: '🎓',
      requiredValue: 1,
      points: 10,
      tier: AchievementTier.bronze,
    ),
    const Achievement(
      id: 'lessons_5',
      title: 'Aprendiz',
      description: 'Completa 5 lecciones',
      category: AchievementCategory.lessons,
      icon: '📚',
      requiredValue: 5,
      points: 25,
      tier: AchievementTier.bronze,
    ),
    const Achievement(
      id: 'lessons_10',
      title: 'Estudiante Dedicado',
      description: 'Completa 10 lecciones',
      category: AchievementCategory.lessons,
      icon: '📖',
      requiredValue: 10,
      points: 50,
      tier: AchievementTier.silver,
    ),
    const Achievement(
      id: 'lessons_25',
      title: 'Explorador',
      description: 'Completa 25 lecciones',
      category: AchievementCategory.lessons,
      icon: '🧭',
      requiredValue: 25,
      points: 100,
      tier: AchievementTier.silver,
    ),
    const Achievement(
      id: 'lessons_50',
      title: 'Avanzado',
      description: 'Completa 50 lecciones',
      category: AchievementCategory.lessons,
      icon: '🌟',
      requiredValue: 50,
      points: 200,
      tier: AchievementTier.gold,
    ),
    const Achievement(
      id: 'lessons_100',
      title: 'Maestro del Aprendizaje',
      description: 'Completa 100 lecciones',
      category: AchievementCategory.lessons,
      icon: '🏆',
      requiredValue: 100,
      points: 500,
      tier: AchievementTier.platinum,
    ),

    // === RACHAS ===
    const Achievement(
      id: 'streak_3',
      title: 'Racha de 3 Días',
      description: 'Practica 3 días seguidos',
      category: AchievementCategory.streaks,
      icon: '🔥',
      requiredValue: 3,
      points: 30,
      tier: AchievementTier.bronze,
    ),
    const Achievement(
      id: 'streak_7',
      title: 'Guerrero Semanal',
      description: 'Practica 7 días seguidos',
      category: AchievementCategory.streaks,
      icon: '⚡',
      requiredValue: 7,
      points: 75,
      tier: AchievementTier.silver,
    ),
    const Achievement(
      id: 'streak_14',
      title: 'Quincenal Imparable',
      description: 'Practica 14 días seguidos',
      category: AchievementCategory.streaks,
      icon: '💪',
      requiredValue: 14,
      points: 150,
      tier: AchievementTier.gold,
    ),
    const Achievement(
      id: 'streak_30',
      title: 'Maestro Mensual',
      description: 'Practica 30 días seguidos',
      category: AchievementCategory.streaks,
      icon: '👑',
      requiredValue: 30,
      points: 300,
      tier: AchievementTier.platinum,
    ),

    // === PUNTUACIONES PERFECTAS ===
    const Achievement(
      id: 'perfect_1',
      title: 'Perfección',
      description: 'Obtén tu primera puntuación perfecta',
      category: AchievementCategory.perfectScores,
      icon: '✨',
      requiredValue: 1,
      points: 15,
      tier: AchievementTier.bronze,
    ),
    const Achievement(
      id: 'perfect_5',
      title: 'Precisión',
      description: 'Obtén 5 puntuaciones perfectas',
      category: AchievementCategory.perfectScores,
      icon: '🎯',
      requiredValue: 5,
      points: 50,
      tier: AchievementTier.silver,
    ),
    const Achievement(
      id: 'perfect_10',
      title: 'Experto',
      description: 'Obtén 10 puntuaciones perfectas',
      category: AchievementCategory.perfectScores,
      icon: '💯',
      requiredValue: 10,
      points: 100,
      tier: AchievementTier.gold,
    ),

    // === MÓDULOS ===
    const Achievement(
      id: 'module_first',
      title: 'Módulo Completado',
      description: 'Completa tu primer módulo',
      category: AchievementCategory.modules,
      icon: '📦',
      requiredValue: 1,
      points: 50,
      tier: AchievementTier.bronze,
    ),
    const Achievement(
      id: 'module_5',
      title: 'Coleccionista',
      description: 'Completa 5 módulos',
      category: AchievementCategory.modules,
      icon: '🗃️',
      requiredValue: 5,
      points: 150,
      tier: AchievementTier.silver,
    ),
    const Achievement(
      id: 'module_10',
      title: 'Conquistador',
      description: 'Completa 10 módulos',
      category: AchievementCategory.modules,
      icon: '🏅',
      requiredValue: 10,
      points: 300,
      tier: AchievementTier.gold,
    ),

    // === HITOS ===
    const Achievement(
      id: 'first_activity',
      title: 'Primer Paso',
      description: 'Completa tu primera actividad',
      category: AchievementCategory.milestones,
      icon: '👋',
      requiredValue: 1,
      points: 5,
      tier: AchievementTier.bronze,
    ),
    const Achievement(
      id: 'early_bird',
      title: 'Madrugador',
      description: 'Practica antes de las 8:00 AM',
      category: AchievementCategory.milestones,
      icon: '🌅',
      requiredValue: 1,
      points: 20,
      tier: AchievementTier.bronze,
    ),
    const Achievement(
      id: 'night_owl',
      title: 'Noctámbulo',
      description: 'Practica después de las 10:00 PM',
      category: AchievementCategory.milestones,
      icon: '🦉',
      requiredValue: 1,
      points: 20,
      tier: AchievementTier.bronze,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }
}
