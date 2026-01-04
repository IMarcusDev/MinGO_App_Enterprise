import 'dart:convert';

import 'package:mingo/core/cache/cache_service.dart';

import '../models/content_models.dart';

/// DataSource local para contenido usando Hive
abstract class ContentLocalDataSource {
  // Age Categories
  Future<void> cacheAgeCategories(List<AgeCategoryModel> categories);
  List<AgeCategoryModel>? getCachedAgeCategories();

  // Level Sections
  Future<void> cacheLevelSections(String ageCategoryId, List<LevelSectionModel> levels);
  List<LevelSectionModel>? getCachedLevelSections(String ageCategoryId);

  // Content Categories
  Future<void> cacheContentCategories(List<ContentCategoryModel> categories);
  List<ContentCategoryModel>? getCachedContentCategories();

  // Modules
  Future<void> cacheModules(String levelSectionId, List<ModuleModel> modules);
  List<ModuleModel>? getCachedModules(String levelSectionId);

  // Lessons
  Future<void> cacheLessons(String moduleId, List<LessonModel> lessons);
  List<LessonModel>? getCachedLessons(String moduleId);

  // Lesson Detail
  Future<void> cacheLessonDetail(LessonModel lesson);
  LessonModel? getCachedLessonDetail(String lessonId);

  // Activities
  Future<void> cacheActivities(String lessonId, List<ActivityModel> activities);
  List<ActivityModel>? getCachedActivities(String lessonId);

  // Utils
  Future<void> clearContentCache();
  bool hasValidCache(String key);
}

class ContentLocalDataSourceImpl implements ContentLocalDataSource {
  final CacheService cacheService;

  // Duración del caché (24 horas por defecto)
  static const Duration _cacheDuration = Duration(hours: 24);

  ContentLocalDataSourceImpl({required this.cacheService});

  // ============================================
  // AGE CATEGORIES
  // ============================================

  @override
  Future<void> cacheAgeCategories(List<AgeCategoryModel> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    await cacheService.putWithExpiry(
      'content_cache',
      CacheService.ageCategoriesKey,
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<AgeCategoryModel>? getCachedAgeCategories() {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'content_cache',
      CacheService.ageCategoriesKey,
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => AgeCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // LEVEL SECTIONS
  // ============================================

  @override
  Future<void> cacheLevelSections(
    String ageCategoryId,
    List<LevelSectionModel> levels,
  ) async {
    final jsonList = levels.map((l) => l.toJson()).toList();
    await cacheService.putWithExpiry(
      'content_cache',
      CacheService.levelSectionsKey(ageCategoryId),
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<LevelSectionModel>? getCachedLevelSections(String ageCategoryId) {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'content_cache',
      CacheService.levelSectionsKey(ageCategoryId),
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => LevelSectionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // CONTENT CATEGORIES
  // ============================================

  @override
  Future<void> cacheContentCategories(List<ContentCategoryModel> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    await cacheService.putWithExpiry(
      'content_cache',
      CacheService.contentCategoriesKey,
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<ContentCategoryModel>? getCachedContentCategories() {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'content_cache',
      CacheService.contentCategoriesKey,
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => ContentCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // MODULES
  // ============================================

  @override
  Future<void> cacheModules(String levelSectionId, List<ModuleModel> modules) async {
    final jsonList = modules.map((m) => m.toJson()).toList();
    await cacheService.putWithExpiry(
      'content_cache',
      CacheService.modulesKey(levelSectionId),
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<ModuleModel>? getCachedModules(String levelSectionId) {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'content_cache',
      CacheService.modulesKey(levelSectionId),
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => ModuleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // LESSONS
  // ============================================

  @override
  Future<void> cacheLessons(String moduleId, List<LessonModel> lessons) async {
    final jsonList = lessons.map((l) => l.toJson()).toList();
    await cacheService.putWithExpiry(
      'content_cache',
      CacheService.lessonsKey(moduleId),
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<LessonModel>? getCachedLessons(String moduleId) {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'content_cache',
      CacheService.lessonsKey(moduleId),
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => LessonModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // LESSON DETAIL
  // ============================================

  @override
  Future<void> cacheLessonDetail(LessonModel lesson) async {
    await cacheService.putWithExpiry(
      'content_cache',
      CacheService.lessonDetailKey(lesson.id),
      jsonEncode(lesson.toJson()),
      expiry: _cacheDuration,
    );
  }

  @override
  LessonModel? getCachedLessonDetail(String lessonId) {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'content_cache',
      CacheService.lessonDetailKey(lessonId),
    );
    if (jsonStr == null) return null;

    return LessonModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  // ============================================
  // ACTIVITIES
  // ============================================

  @override
  Future<void> cacheActivities(String lessonId, List<ActivityModel> activities) async {
    final jsonList = activities.map((a) => a.toJson()).toList();
    await cacheService.putWithExpiry(
      'content_cache',
      CacheService.activitiesKey(lessonId),
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<ActivityModel>? getCachedActivities(String lessonId) {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'content_cache',
      CacheService.activitiesKey(lessonId),
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // UTILS
  // ============================================

  @override
  Future<void> clearContentCache() async {
    await cacheService.clearBox('content_cache');
  }

  @override
  bool hasValidCache(String key) {
    return !cacheService.isExpired('content_cache', key);
  }
}
