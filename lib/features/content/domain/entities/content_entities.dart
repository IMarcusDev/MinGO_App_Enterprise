import 'package:equatable/equatable.dart';

/// Tipos de nivel - Alineado con API
enum LevelType {
  principiante('PRINCIPIANTE'),
  intermedio('INTERMEDIO'),
  avanzado('AVANZADO');

  final String value;
  const LevelType(this.value);

  static LevelType fromString(String value) {
    return LevelType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => LevelType.principiante,
    );
  }
}

/// Tipos de actividad - Alineado con API
enum ActivityType {
  video('VIDEO'),
  quiz('QUIZ'),
  practice('PRACTICE'),
  game('GAME');

  final String value;
  const ActivityType(this.value);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ActivityType.video,
    );
  }
}

// ============================================
// AgeCategory - Categoría de edad
// ============================================
class AgeCategory extends Equatable {
  final String id;
  final String name;
  final int minAge;
  final int maxAge;
  final String? description;
  final int orderIndex;

  const AgeCategory({
    required this.id,
    required this.name,
    required this.minAge,
    required this.maxAge,
    this.description,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [id, name, minAge, maxAge, orderIndex];
}

// ============================================
// LevelSection - Sección de nivel (Principiante, Intermedio, Avanzado)
// ============================================
class LevelSection extends Equatable {
  final String id;
  final String name;
  final LevelType level;
  final int orderIndex;
  final String? description;
  final bool isUnlocked;

  const LevelSection({
    required this.id,
    required this.name,
    required this.level,
    required this.orderIndex,
    this.description,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [id, name, level, orderIndex, isUnlocked];
}

// ============================================
// ContentCategory - Categoría de contenido (Saludos, Familia, etc.)
// ============================================
class ContentCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final int orderIndex;

  const ContentCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [id, name, orderIndex];
}

// ============================================
// Module - Módulo de contenido
// ============================================
class Module extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String ageCategoryId;
  final String levelSectionId;
  final String contentCategoryId;
  final int orderIndex;
  final String? thumbnailUrl;
  final bool isActive;
  final int lessonsCount;

  const Module({
    required this.id,
    required this.title,
    this.description,
    required this.ageCategoryId,
    required this.levelSectionId,
    required this.contentCategoryId,
    required this.orderIndex,
    this.thumbnailUrl,
    required this.isActive,
    required this.lessonsCount,
  });

  @override
  List<Object?> get props => [id, title, levelSectionId, orderIndex];
}

// ============================================
// Lesson - Lección
// ============================================
class LessonProgress extends Equatable {
  final bool completed;
  final double accuracy;

  const LessonProgress({
    required this.completed,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [completed, accuracy];
}

class Lesson extends Equatable {
  final String id;
  final String moduleId;
  final String title;
  final String? description;
  final int orderIndex;
  final int? duration;
  final bool isActive;
  final int activitiesCount;
  final LessonProgress? userProgress;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.duration,
    required this.isActive,
    required this.activitiesCount,
    this.userProgress,
  });

  bool get isCompleted => userProgress?.completed ?? false;

  @override
  List<Object?> get props => [id, moduleId, title, orderIndex];
}

// ============================================
// Activity - Actividad de aprendizaje
// ============================================
class Activity extends Equatable {
  final String id;
  final String lessonId;
  final String title;
  final String? description;
  final ActivityType activityType;
  final int orderIndex;
  final int points;
  final bool isActive;

  const Activity({
    required this.id,
    required this.lessonId,
    required this.title,
    this.description,
    required this.activityType,
    required this.orderIndex,
    required this.points,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, lessonId, title, activityType, orderIndex];
}

// ============================================
// SignContent - Contenido de seña
// ============================================
class SignContent extends Equatable {
  final String id;
  final String activityId;
  final String word;
  final String? videoUrl;
  final String? imageUrl;
  final String? audioUrl;
  final String? description;

  const SignContent({
    required this.id,
    required this.activityId,
    required this.word,
    this.videoUrl,
    this.imageUrl,
    this.audioUrl,
    this.description,
  });

  @override
  List<Object?> get props => [id, activityId, word];
}
