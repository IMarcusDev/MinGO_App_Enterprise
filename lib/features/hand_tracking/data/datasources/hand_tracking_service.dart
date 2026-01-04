import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mingo/features/hand_tracking/domain/entities/hand_landmark_entities.dart';

/// Servicio de Hand Tracking usando MediaPipe via Platform Channels
class HandTrackingService {
  static const MethodChannel _channel = MethodChannel('com.mingo.hand_tracking/methods');
  static const EventChannel _eventChannel = EventChannel('com.mingo.hand_tracking/stream');

  static HandTrackingService? _instance;
  static HandTrackingService get instance => _instance ??= HandTrackingService._();

  HandTrackingService._();

  StreamSubscription? _subscription;
  final _frameController = StreamController<HandTrackingFrame>.broadcast();
  
  bool _isInitialized = false;
  bool _isTracking = false;

  /// Stream de frames de hand tracking
  Stream<HandTrackingFrame> get frameStream => _frameController.stream;
  
  /// Estado actual
  bool get isInitialized => _isInitialized;
  bool get isTracking => _isTracking;

  /// Inicializar MediaPipe
  Future<bool> initialize({
    int maxHands = 2,
    double minDetectionConfidence = 0.5,
    double minTrackingConfidence = 0.5,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize', {
        'maxHands': maxHands,
        'minDetectionConfidence': minDetectionConfidence,
        'minTrackingConfidence': minTrackingConfidence,
      });
      _isInitialized = result ?? false;
      return _isInitialized;
    } on PlatformException catch (e) {
      print('Error initializing HandTracking: ${e.message}');
      return false;
    }
  }

  /// Iniciar tracking
  Future<bool> startTracking() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      await _channel.invokeMethod('startTracking');
      _isTracking = true;
      
      // Escuchar stream de frames
      _subscription = _eventChannel
          .receiveBroadcastStream()
          .map((data) => _parseFrame(data))
          .listen(
            (frame) => _frameController.add(frame),
            onError: (error) => print('HandTracking stream error: $error'),
          );
      
      return true;
    } on PlatformException catch (e) {
      print('Error starting tracking: ${e.message}');
      return false;
    }
  }

  /// Detener tracking
  Future<void> stopTracking() async {
    try {
      await _channel.invokeMethod('stopTracking');
      await _subscription?.cancel();
      _subscription = null;
      _isTracking = false;
    } on PlatformException catch (e) {
      print('Error stopping tracking: ${e.message}');
    }
  }

  /// Procesar un frame de imagen (para uso con image picker)
  Future<HandTrackingFrame> processImage(Uint8List imageBytes) async {
    try {
      final result = await _channel.invokeMethod<String>('processImage', {
        'imageBytes': imageBytes,
      });
      if (result != null) {
        return _parseFrame(result);
      }
    } on PlatformException catch (e) {
      print('Error processing image: ${e.message}');
    }
    return HandTrackingFrame.empty();
  }

  /// Liberar recursos
  Future<void> dispose() async {
    await stopTracking();
    try {
      await _channel.invokeMethod('dispose');
    } catch (_) {}
    _isInitialized = false;
    await _frameController.close();
  }

  /// Parsear frame desde JSON nativo
  HandTrackingFrame _parseFrame(dynamic data) {
    try {
      final Map<String, dynamic> json;
      if (data is String) {
        json = jsonDecode(data);
      } else if (data is Map) {
        json = Map<String, dynamic>.from(data);
      } else {
        return HandTrackingFrame.empty();
      }
      return HandTrackingFrame.fromJson(json);
    } catch (e) {
      print('Error parsing frame: $e');
      return HandTrackingFrame.empty();
    }
  }

  /// Verificar si MediaPipe está disponible en el dispositivo
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Obtener información del dispositivo y capacidades
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod<Map>('getDeviceInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (_) {
      return {};
    }
  }
}

/// Configuración del hand tracker
class HandTrackerConfig {
  final int maxHands;
  final double minDetectionConfidence;
  final double minTrackingConfidence;
  final bool runningMode; // true = video, false = image

  const HandTrackerConfig({
    this.maxHands = 2,
    this.minDetectionConfidence = 0.5,
    this.minTrackingConfidence = 0.5,
    this.runningMode = true,
  });

  Map<String, dynamic> toJson() => {
    'maxHands': maxHands,
    'minDetectionConfidence': minDetectionConfidence,
    'minTrackingConfidence': minTrackingConfidence,
    'runningMode': runningMode,
  };
}
