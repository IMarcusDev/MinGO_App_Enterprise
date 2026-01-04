import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio centralizado de caché usando Hive
class CacheService {
  static const String _userBox = 'user_cache';
  static const String _contentBox = 'content_cache';
  static const String _progressBox = 'progress_cache';
  static const String _syncBox = 'sync_queue';
  static const String _settingsBox = 'settings_cache';

  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  bool _initialized = false;

  /// Inicializar Hive
  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    // Abrir boxes
    await Hive.openBox(_userBox);
    await Hive.openBox(_contentBox);
    await Hive.openBox(_progressBox);
    await Hive.openBox<Map>(_syncBox);
    await Hive.openBox(_settingsBox);

    _initialized = true;
  }

  // ============================================
  // BOXES
  // ============================================
  Box get userBox => Hive.box(_userBox);
  Box get contentBox => Hive.box(_contentBox);
  Box get progressBox => Hive.box(_progressBox);
  Box<Map> get syncBox => Hive.box<Map>(_syncBox);
  Box get settingsBox => Hive.box(_settingsBox);

  // ============================================
  // MÉTODOS GENÉRICOS
  // ============================================

  /// Guardar dato con key
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  /// Obtener dato por key
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  /// Eliminar dato por key
  Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  /// Verificar si existe key
  bool containsKey(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.containsKey(key);
  }

  /// Limpiar box completo
  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  /// Limpiar todo el caché
  Future<void> clearAll() async {
    await userBox.clear();
    await contentBox.clear();
    await progressBox.clear();
    await syncBox.clear();
  }

  // ============================================
  // MÉTODOS CON EXPIRACIÓN
  // ============================================

  /// Guardar con timestamp para control de expiración
  Future<void> putWithExpiry(
    String boxName,
    String key,
    dynamic value, {
    Duration expiry = const Duration(hours: 24),
  }) async {
    final box = Hive.box(boxName);
    final data = {
      'value': value,
      'expiry': DateTime.now().add(expiry).millisecondsSinceEpoch,
    };
    await box.put(key, data);
  }

  /// Obtener verificando expiración
  T? getIfNotExpired<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);

    if (data == null) return null;

    if (data is Map && data.containsKey('expiry')) {
      final expiry = data['expiry'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        // Expirado, eliminar
        box.delete(key);
        return null;
      }
      return data['value'] as T?;
    }

    return data as T?;
  }

  /// Verificar si dato está expirado
  bool isExpired(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);

    if (data == null) return true;

    if (data is Map && data.containsKey('expiry')) {
      final expiry = data['expiry'] as int;
      return DateTime.now().millisecondsSinceEpoch > expiry;
    }

    return false;
  }

  // ============================================
  // COLA DE SINCRONIZACIÓN
  // ============================================

  /// Agregar operación pendiente a la cola
  Future<void> addToSyncQueue(SyncOperation operation) async {
    final key = '${operation.type}_${DateTime.now().millisecondsSinceEpoch}';
    await syncBox.put(key, operation.toMap());
  }

  /// Obtener todas las operaciones pendientes
  List<SyncOperation> getPendingSyncOperations() {
    return syncBox.values
        .map((map) => SyncOperation.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  /// Eliminar operación de la cola
  Future<void> removeSyncOperation(String key) async {
    await syncBox.delete(key);
  }

  /// Limpiar cola de sincronización
  Future<void> clearSyncQueue() async {
    await syncBox.clear();
  }

  // ============================================
  // HELPERS DE CONTENT
  // ============================================

  /// Keys para content cache
  static String levelSectionsKey(String ageCategoryId) => 
      'levels_$ageCategoryId';
  static String modulesKey(String levelSectionId) => 
      'modules_$levelSectionId';
  static String lessonsKey(String moduleId) => 
      'lessons_$moduleId';
  static String lessonDetailKey(String lessonId) => 
      'lesson_$lessonId';
  static String activitiesKey(String lessonId) => 
      'activities_$lessonId';
  static const String ageCategoriesKey = 'age_categories';
  static const String contentCategoriesKey = 'content_categories';

  // ============================================
  // HELPERS DE PROGRESS
  // ============================================

  static const String userProgressKey = 'user_progress';
  static const String userStatsKey = 'user_stats';
  static const String streakKey = 'streak';
  static const String dailyActivityKey = 'daily_activity';

  // ============================================
  // HELPERS DE USER
  // ============================================

  static const String currentUserKey = 'current_user';
  static const String childrenKey = 'children';
  static const String selectedChildKey = 'selected_child';
}

/// Tipos de operaciones para sincronizar
enum SyncOperationType {
  recordAttempt,
  completeLesson,
  createChild,
  updateChild,
  deleteChild,
}

/// Operación pendiente de sincronización
class SyncOperation {
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  SyncOperation({
    required this.type,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'type': type.index,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      type: SyncOperationType.values[map['type'] as int],
      data: Map<String, dynamic>.from(map['data'] as Map),
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
    );
  }

  SyncOperation copyWith({int? retryCount}) {
    return SyncOperation(
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
