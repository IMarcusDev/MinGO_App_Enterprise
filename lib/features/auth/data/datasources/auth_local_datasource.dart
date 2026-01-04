import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

/// Datasource local para caché de autenticación
abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<bool> hasValidSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String _cachedUserKey = 'cached_user';
  static const String _sessionTimestampKey = 'session_timestamp';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedUserKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, jsonString);
      await sharedPreferences.setInt(
        _sessionTimestampKey, 
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw const CacheException(message: 'Error al guardar usuario en caché');
    }
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedUserKey);
    await sharedPreferences.remove(_sessionTimestampKey);
  }

  @override
  Future<bool> hasValidSession() async {
    final timestamp = sharedPreferences.getInt(_sessionTimestampKey);
    if (timestamp == null) return false;

    final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    // Sesión válida por 7 días
    final difference = now.difference(sessionTime);
    return difference.inDays < 7;
  }
}
