import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/achievement_entities.dart';

/// Datasource local para logros
abstract class AchievementLocalDataSource {
  /// Obtener logros desbloqueados del caché
  List<UnlockedAchievement>? getCachedUnlockedAchievements();

  /// Guardar logros desbloqueados en caché
  Future<void> cacheUnlockedAchievements(List<UnlockedAchievement> achievements);

  /// Agregar un logro desbloqueado al caché
  Future<void> addUnlockedAchievement(UnlockedAchievement achievement);

  /// Verificar si un logro está desbloqueado
  bool isAchievementUnlocked(String achievementId);

  /// Obtener fecha de desbloqueo de un logro
  DateTime? getUnlockDate(String achievementId);

  /// Limpiar caché de logros
  Future<void> clearAchievementsCache();

  /// Obtener puntos totales del usuario
  int getTotalPoints();

  /// Guardar puntos totales
  Future<void> saveTotalPoints(int points);
}

class AchievementLocalDataSourceImpl implements AchievementLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _unlockedAchievementsKey = 'unlocked_achievements';
  static const String _totalPointsKey = 'achievement_total_points';

  AchievementLocalDataSourceImpl({required this.sharedPreferences});

  @override
  List<UnlockedAchievement>? getCachedUnlockedAchievements() {
    final jsonString = sharedPreferences.getString(_unlockedAchievementsKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => _parseUnlockedAchievement(item)).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheUnlockedAchievements(List<UnlockedAchievement> achievements) async {
    final jsonList = achievements.map((a) => _serializeUnlockedAchievement(a)).toList();
    await sharedPreferences.setString(_unlockedAchievementsKey, json.encode(jsonList));
  }

  @override
  Future<void> addUnlockedAchievement(UnlockedAchievement achievement) async {
    final cached = getCachedUnlockedAchievements() ?? [];

    // Verificar si ya existe
    if (cached.any((a) => a.achievementId == achievement.achievementId)) {
      return;
    }

    cached.add(achievement);
    await cacheUnlockedAchievements(cached);

    // Actualizar puntos totales
    final currentPoints = getTotalPoints();
    await saveTotalPoints(currentPoints + achievement.achievement.points);
  }

  @override
  bool isAchievementUnlocked(String achievementId) {
    final cached = getCachedUnlockedAchievements();
    if (cached == null) return false;
    return cached.any((a) => a.achievementId == achievementId);
  }

  @override
  DateTime? getUnlockDate(String achievementId) {
    final cached = getCachedUnlockedAchievements();
    if (cached == null) return null;

    try {
      final achievement = cached.firstWhere((a) => a.achievementId == achievementId);
      return achievement.unlockedAt;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAchievementsCache() async {
    await sharedPreferences.remove(_unlockedAchievementsKey);
    await sharedPreferences.remove(_totalPointsKey);
  }

  @override
  int getTotalPoints() {
    return sharedPreferences.getInt(_totalPointsKey) ?? 0;
  }

  @override
  Future<void> saveTotalPoints(int points) async {
    await sharedPreferences.setInt(_totalPointsKey, points);
  }

  // === Helpers de serialización ===

  UnlockedAchievement _parseUnlockedAchievement(Map<String, dynamic> json) {
    final achievementDef = AchievementDefinitions.getById(json['achievement_id']);

    return UnlockedAchievement(
      id: json['id'] ?? '',
      achievementId: json['achievement_id'] ?? '',
      userId: json['user_id'] ?? '',
      unlockedAt: DateTime.parse(json['unlocked_at']),
      achievement: achievementDef ?? Achievement(
        id: json['achievement_id'] ?? '',
        title: json['achievement_title'] ?? '',
        description: json['achievement_description'] ?? '',
        category: AchievementCategory.fromString(json['category'] ?? ''),
        icon: json['icon'] ?? '🏆',
        requiredValue: json['required_value'] ?? 0,
        points: json['points'] ?? 0,
        tier: AchievementTier.fromString(json['tier'] ?? ''),
      ),
    );
  }

  Map<String, dynamic> _serializeUnlockedAchievement(UnlockedAchievement achievement) {
    return {
      'id': achievement.id,
      'achievement_id': achievement.achievementId,
      'user_id': achievement.userId,
      'unlocked_at': achievement.unlockedAt.toIso8601String(),
      'achievement_title': achievement.achievement.title,
      'achievement_description': achievement.achievement.description,
      'category': achievement.achievement.category.value,
      'icon': achievement.achievement.icon,
      'required_value': achievement.achievement.requiredValue,
      'points': achievement.achievement.points,
      'tier': achievement.achievement.tier.value,
    };
  }
}
