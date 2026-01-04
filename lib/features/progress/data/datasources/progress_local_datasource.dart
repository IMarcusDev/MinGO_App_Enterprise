import 'dart:convert';

import 'package:mingo/core/cache/cache_service.dart';

import '../models/progress_models.dart';

/// DataSource local para progreso usando Hive
abstract class ProgressLocalDataSource {
  // Progress
  Future<void> cacheUserProgress(List<LessonProgressModel> progress);
  List<LessonProgressModel>? getCachedUserProgress();

  // Stats
  Future<void> cacheUserStats(UserStatsModel stats);
  UserStatsModel? getCachedUserStats();

  // Streak
  Future<void> cacheStreak(StreakModel streak);
  StreakModel? getCachedStreak();

  // Daily Activity
  Future<void> cacheDailyActivity(List<DailyActivityModel> activity);
  List<DailyActivityModel>? getCachedDailyActivity();

  // Operaciones offline
  Future<void> saveOfflineAttempt(Map<String, dynamic> attemptData);
  List<Map<String, dynamic>> getOfflineAttempts();
  Future<void> clearOfflineAttempts();

  // Utils
  Future<void> clearProgressCache();
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final CacheService cacheService;

  static const Duration _cacheDuration = Duration(hours: 1);
  static const String _offlineAttemptsKey = 'offline_attempts';

  ProgressLocalDataSourceImpl({required this.cacheService});

  // ============================================
  // USER PROGRESS
  // ============================================

  @override
  Future<void> cacheUserProgress(List<LessonProgressModel> progress) async {
    final jsonList = progress.map((p) => _lessonProgressToJson(p)).toList();
    await cacheService.putWithExpiry(
      'progress_cache',
      CacheService.userProgressKey,
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<LessonProgressModel>? getCachedUserProgress() {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'progress_cache',
      CacheService.userProgressKey,
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => LessonProgressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // USER STATS
  // ============================================

  @override
  Future<void> cacheUserStats(UserStatsModel stats) async {
    await cacheService.putWithExpiry(
      'progress_cache',
      CacheService.userStatsKey,
      jsonEncode(_userStatsToJson(stats)),
      expiry: _cacheDuration,
    );
  }

  @override
  UserStatsModel? getCachedUserStats() {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'progress_cache',
      CacheService.userStatsKey,
    );
    if (jsonStr == null) return null;

    return UserStatsModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  // ============================================
  // STREAK
  // ============================================

  @override
  Future<void> cacheStreak(StreakModel streak) async {
    await cacheService.putWithExpiry(
      'progress_cache',
      CacheService.streakKey,
      jsonEncode(_streakToJson(streak)),
      expiry: _cacheDuration,
    );
  }

  @override
  StreakModel? getCachedStreak() {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'progress_cache',
      CacheService.streakKey,
    );
    if (jsonStr == null) return null;

    return StreakModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  // ============================================
  // DAILY ACTIVITY
  // ============================================

  @override
  Future<void> cacheDailyActivity(List<DailyActivityModel> activity) async {
    final jsonList = activity.map((a) => _dailyActivityToJson(a)).toList();
    await cacheService.putWithExpiry(
      'progress_cache',
      CacheService.dailyActivityKey,
      jsonEncode(jsonList),
      expiry: _cacheDuration,
    );
  }

  @override
  List<DailyActivityModel>? getCachedDailyActivity() {
    final jsonStr = cacheService.getIfNotExpired<String>(
      'progress_cache',
      CacheService.dailyActivityKey,
    );
    if (jsonStr == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => DailyActivityModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // OFFLINE ATTEMPTS
  // ============================================

  @override
  Future<void> saveOfflineAttempt(Map<String, dynamic> attemptData) async {
    final attempts = getOfflineAttempts();
    attempts.add({
      ...attemptData,
      'savedAt': DateTime.now().toIso8601String(),
    });
    
    await cacheService.put(
      'progress_cache',
      _offlineAttemptsKey,
      jsonEncode(attempts),
    );
  }

  @override
  List<Map<String, dynamic>> getOfflineAttempts() {
    final jsonStr = cacheService.get<String>(
      'progress_cache',
      _offlineAttemptsKey,
    );
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => Map<String, dynamic>.from(json as Map))
        .toList();
  }

  @override
  Future<void> clearOfflineAttempts() async {
    await cacheService.delete('progress_cache', _offlineAttemptsKey);
  }

  // ============================================
  // UTILS
  // ============================================

  @override
  Future<void> clearProgressCache() async {
    await cacheService.clearBox('progress_cache');
  }

  // Helpers para serialización
  Map<String, dynamic> _lessonProgressToJson(LessonProgressModel p) => {
        'id': p.id,
        'userId': p.userId,
        'lessonId': p.lessonId,
        'lessonTitle': p.lessonTitle,
        'completed': p.completed,
        'completedAt': p.completedAt?.toIso8601String(),
        'accuracy': p.accuracy,
        'totalAttempts': p.totalAttempts,
        'correctAttempts': p.correctAttempts,
        'timeSpent': p.timeSpent,
        'createdAt': p.createdAt.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _userStatsToJson(UserStatsModel s) => {
        'userId': s.userId,
        'totalLessonsStarted': s.totalLessonsStarted,
        'totalLessonsCompleted': s.totalLessonsCompleted,
        'averageAccuracy': s.averageAccuracy,
        'totalTimeSpent': s.totalTimeSpent,
        'unlockedLevels': s.unlockedLevels,
      };

  Map<String, dynamic> _streakToJson(StreakModel s) => {
        'currentStreak': s.currentStreak,
        'longestStreak': s.longestStreak,
        'lastActivityDate': s.lastActivityDate?.toIso8601String(),
        'isActiveToday': s.isActiveToday,
      };

  Map<String, dynamic> _dailyActivityToJson(DailyActivityModel a) => {
        'date': a.date.toIso8601String(),
        'lessonsCompleted': a.lessonsCompleted,
        'timeSpent': a.timeSpent,
        'accuracy': a.accuracy,
      };
}
