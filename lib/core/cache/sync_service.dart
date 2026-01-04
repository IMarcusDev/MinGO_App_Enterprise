import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';
import 'cache_service.dart';

/// Servicio de sincronización en background
class SyncService {
  final NetworkInfo networkInfo;
  final CacheService cacheService;
  
  // Callbacks para sincronizar cada tipo de operación
  final Future<bool> Function(Map<String, dynamic>)? onRecordAttempt;
  final Future<bool> Function(Map<String, dynamic>)? onCompleteLesson;
  final Future<bool> Function(Map<String, dynamic>)? onCreateChild;
  final Future<bool> Function(Map<String, dynamic>)? onUpdateChild;
  final Future<bool> Function(Map<String, dynamic>)? onDeleteChild;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  static const int _maxRetries = 3;
  static const Duration _syncInterval = Duration(minutes: 5);

  SyncService({
    required this.networkInfo,
    required this.cacheService,
    this.onRecordAttempt,
    this.onCompleteLesson,
    this.onCreateChild,
    this.onUpdateChild,
    this.onDeleteChild,
  });

  /// Iniciar servicio de sincronización
  void start() {
    // Escuchar cambios de conectividad
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (result) async {
        final hasConnection = result != ConnectivityResult.none;
        if (hasConnection) {
          await syncPendingOperations();
        }
      },
    );

    // Timer periódico para sincronizar
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      syncPendingOperations();
    });

    // Sincronizar al iniciar
    syncPendingOperations();
  }

  /// Detener servicio
  void stop() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  /// Sincronizar operaciones pendientes
  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    _isSyncing = true;

    try {
      for (final entry in cacheService.syncBox.toMap().entries) {
        final key = entry.key as String;
        final operation = SyncOperation.fromMap(
          Map<String, dynamic>.from(entry.value),
        );

        // Saltar si excede reintentos
        if (operation.retryCount >= _maxRetries) {
          debugPrint('SyncService: Operación $key excedió reintentos, eliminando');
          await cacheService.removeSyncOperation(key);
          continue;
        }

        final success = await _executeOperation(operation);

        if (success) {
          await cacheService.removeSyncOperation(key);
          debugPrint('SyncService: Operación $key sincronizada');
        } else {
          // Incrementar contador de reintentos
          final updated = operation.copyWith(retryCount: operation.retryCount + 1);
          await cacheService.syncBox.put(key, updated.toMap());
          debugPrint('SyncService: Operación $key falló, reintento ${updated.retryCount}');
        }
      }
    } catch (e) {
      debugPrint('SyncService: Error en sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Ejecutar una operación
  Future<bool> _executeOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.recordAttempt:
          if (onRecordAttempt != null) {
            return await onRecordAttempt!(operation.data);
          }
          break;
        case SyncOperationType.completeLesson:
          if (onCompleteLesson != null) {
            return await onCompleteLesson!(operation.data);
          }
          break;
        case SyncOperationType.createChild:
          if (onCreateChild != null) {
            return await onCreateChild!(operation.data);
          }
          break;
        case SyncOperationType.updateChild:
          if (onUpdateChild != null) {
            return await onUpdateChild!(operation.data);
          }
          break;
        case SyncOperationType.deleteChild:
          if (onDeleteChild != null) {
            return await onDeleteChild!(operation.data);
          }
          break;
      }
      return true; // Si no hay callback, consideramos exitoso
    } catch (e) {
      debugPrint('SyncService: Error ejecutando operación: $e');
      return false;
    }
  }

  /// Obtener número de operaciones pendientes
  int get pendingCount => cacheService.syncBox.length;

  /// Verificar si hay operaciones pendientes
  bool get hasPendingOperations => cacheService.syncBox.isNotEmpty;
}
