import '../../domain/entities/content_entities.dart';

// ============================================
// AgeCategory Model
// ============================================
class AgeCategoryModel extends AgeCategory {
  const AgeCategoryModel({
    required super.id,
    required super.name,
    required super.minAge,
    required super.maxAge,
    super.description,
    required super.orderIndex,
  });

  factory AgeCategoryModel.fromJson(Map<String, dynamic> json) {
    return AgeCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      minAge: json['minAge'] as int,
      maxAge: json['maxAge'] as int,
      description: json['description'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'minAge': minAge,
        'maxAge': maxAge,
        'description': description,
        'orderIndex': orderIndex,
      };
}

// ============================================
// LevelSection Model
// ============================================
class LevelSectionModel extends LevelSection {
  const LevelSectionModel({
    required super.id,
    required super.name,
    required super.level,
    required super.orderIndex,
    super.description,
    required super.isUnlocked,
  });

  factory LevelSectionModel.fromJson(Map<String, dynamic> json) {
    return LevelSectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      level: LevelType.fromString(json['level'] as String),
      orderIndex: json['orderIndex'] as int? ?? 0,
      description: json['description'] as String?,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level.value,
        'orderIndex': orderIndex,
        'description': description,
        'isUnlocked': isUnlocked,
      };
}

// ============================================
// ContentCategory Model
// ============================================
class ContentCategoryModel extends ContentCategory {
  const ContentCategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.iconUrl,
    required super.orderIndex,
  });

  factory ContentCategoryModel.fromJson(Map<String, dynamic> json) {
    return ContentCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'orderIndex': orderIndex,
      };
}

// ============================================
// Module Model
// ============================================
class ModuleModel extends Module {
  const ModuleModel({
    required super.id,
    required super.title,
    super.description,
    required super.ageCategoryId,
    required super.levelSectionId,
    required super.contentCategoryId,
    required super.orderIndex,
    super.thumbnailUrl,
    required super.isActive,
    required super.lessonsCount,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      ageCategoryId: json['ageCategoryId'] as String,
      levelSectionId: json['levelSectionId'] as String,
      contentCategoryId: json['contentCategoryId'] as String,
      orderIndex: json['orderIndex'] as int? ?? 0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lessonsCount: json['lessonsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'ageCategoryId': ageCategoryId,
        'levelSectionId': levelSectionId,
        'contentCategoryId': contentCategoryId,
        'orderIndex': orderIndex,
        'thumbnailUrl': thumbnailUrl,
        'isActive': isActive,
        'lessonsCount': lessonsCount,
      };
}

// ============================================
// Lesson Model
// ============================================
class LessonProgressModel extends LessonProgress {
  const LessonProgressModel({
    required super.completed,
    required super.accuracy,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      completed: json['completed'] as bool? ?? false,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'accuracy': accuracy,
      };
}

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.moduleId,
    required super.title,
    super.description,
    required super.orderIndex,
    super.duration,
    required super.isActive,
    required super.activitiesCount,
    super.userProgress,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    LessonProgressModel? progress;
    if (json['userProgress'] != null) {
      progress = LessonProgressModel.fromJson(
        json['userProgress'] as Map<String, dynamic>,
      );
    }

    return LessonModel(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      duration: json['duration'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      activitiesCount: json['activitiesCount'] as int? ?? 0,
      userProgress: progress,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'description': description,
        'orderIndex': orderIndex,
        'duration': duration,
        'isActive': isActive,
        'activitiesCount': activitiesCount,
        'userProgress': userProgress != null
            ? (userProgress as LessonProgressModel).toJson()
            : null,
      };
}

// ============================================
// Activity Model
// ============================================
class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.lessonId,
    required super.title,
    super.description,
    required super.activityType,
    required super.orderIndex,
    required super.points,
    required super.isActive,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      activityType: ActivityType.fromString(json['activityType'] as String),
      orderIndex: json['orderIndex'] as int? ?? 0,
      points: json['points'] as int? ?? 10,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'title': title,
        'description': description,
        'activityType': activityType.value,
        'orderIndex': orderIndex,
        'points': points,
        'isActive': isActive,
      };
}

// ============================================
// SignContent Model
// ============================================
class SignContentModel extends SignContent {
  const SignContentModel({
    required super.id,
    required super.activityId,
    required super.word,
    super.videoUrl,
    super.imageUrl,
    super.audioUrl,
    super.description,
  });

  factory SignContentModel.fromJson(Map<String, dynamic> json) {
    return SignContentModel(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      word: json['word'] as String,
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'word': word,
        'videoUrl': videoUrl,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'description': description,
      };
}
