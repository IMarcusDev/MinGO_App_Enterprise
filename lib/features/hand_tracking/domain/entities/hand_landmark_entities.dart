import 'dart:math' as math;
import 'package:equatable/equatable.dart';

/// Punto 3D de un landmark de la mano
class HandLandmark extends Equatable {
  final int index;
  final double x; // 0.0 - 1.0 (normalizado)
  final double y; // 0.0 - 1.0 (normalizado)
  final double z; // Profundidad relativa
  final double visibility; // 0.0 - 1.0

  const HandLandmark({
    required this.index,
    required this.x,
    required this.y,
    required this.z,
    this.visibility = 1.0,
  });

  /// Nombre del landmark según MediaPipe
  String get name => HandLandmarkType.values[index].name;
  HandLandmarkType get type => HandLandmarkType.values[index];

  /// Distancia euclidiana a otro landmark
  double distanceTo(HandLandmark other) {
    return math.sqrt(
      math.pow(x - other.x, 2) + 
      math.pow(y - other.y, 2) + 
      math.pow(z - other.z, 2),
    );
  }

  /// Distancia 2D (sin profundidad)
  double distance2DTo(HandLandmark other) {
    return math.sqrt(
      math.pow(x - other.x, 2) + 
      math.pow(y - other.y, 2),
    );
  }

  factory HandLandmark.fromJson(Map<String, dynamic> json) {
    return HandLandmark(
      index: json['index'] ?? 0,
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
      z: (json['z'] ?? 0.0).toDouble(),
      visibility: (json['visibility'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'x': x,
    'y': y,
    'z': z,
    'visibility': visibility,
  };

  @override
  List<Object?> get props => [index, x, y, z, visibility];
}

/// Tipos de landmarks de MediaPipe Hands (21 puntos)
enum HandLandmarkType {
  wrist,            // 0 - Muñeca
  thumbCmc,         // 1 - Pulgar CMC
  thumbMcp,         // 2 - Pulgar MCP
  thumbIp,          // 3 - Pulgar IP
  thumbTip,         // 4 - Punta del pulgar
  indexMcp,         // 5 - Índice MCP
  indexPip,         // 6 - Índice PIP
  indexDip,         // 7 - Índice DIP
  indexTip,         // 8 - Punta del índice
  middleMcp,        // 9 - Medio MCP
  middlePip,        // 10 - Medio PIP
  middleDip,        // 11 - Medio DIP
  middleTip,        // 12 - Punta del medio
  ringMcp,          // 13 - Anular MCP
  ringPip,          // 14 - Anular PIP
  ringDip,          // 15 - Anular DIP
  ringTip,          // 16 - Punta del anular
  pinkyMcp,         // 17 - Meñique MCP
  pinkyPip,         // 18 - Meñique PIP
  pinkyDip,         // 19 - Meñique DIP
  pinkyTip,         // 20 - Punta del meñique
}

/// Resultado de detección de una mano
class HandDetectionResult extends Equatable {
  final List<HandLandmark> landmarks;
  final Handedness handedness; // Izquierda o derecha
  final double confidence; // 0.0 - 1.0
  final DateTime timestamp;

  const HandDetectionResult({
    required this.landmarks,
    required this.handedness,
    required this.confidence,
    required this.timestamp,
  });

  /// Obtener landmark por tipo
  HandLandmark? getLandmark(HandLandmarkType type) {
    final index = type.index;
    if (index < landmarks.length) {
      return landmarks[index];
    }
    return null;
  }

  /// Verificar si todos los dedos están extendidos
  bool get isOpenHand {
    return isFingerExtended(Finger.thumb) &&
           isFingerExtended(Finger.indexFinger) &&
           isFingerExtended(Finger.middle) &&
           isFingerExtended(Finger.ring) &&
           isFingerExtended(Finger.pinky);
  }

  /// Verificar si la mano está cerrada (puño)
  bool get isClosedFist {
    return !isFingerExtended(Finger.indexFinger) &&
           !isFingerExtended(Finger.middle) &&
           !isFingerExtended(Finger.ring) &&
           !isFingerExtended(Finger.pinky);
  }

  /// Verificar si un dedo específico está extendido
  bool isFingerExtended(Finger finger) {
    switch (finger) {
      case Finger.thumb:
        final tip = getLandmark(HandLandmarkType.thumbTip);
        final ip = getLandmark(HandLandmarkType.thumbIp);
        final mcp = getLandmark(HandLandmarkType.thumbMcp);
        if (tip == null || ip == null || mcp == null) return false;
        // Pulgar extendido si la punta está más lejos de la muñeca que MCP
        return tip.distance2DTo(getLandmark(HandLandmarkType.wrist)!) >
               mcp.distance2DTo(getLandmark(HandLandmarkType.wrist)!);

      case Finger.indexFinger:
        return _isFingerExtendedByTip(
          HandLandmarkType.indexTip,
          HandLandmarkType.indexPip,
          HandLandmarkType.indexMcp,
        );
      case Finger.middle:
        return _isFingerExtendedByTip(
          HandLandmarkType.middleTip,
          HandLandmarkType.middlePip,
          HandLandmarkType.middleMcp,
        );
      case Finger.ring:
        return _isFingerExtendedByTip(
          HandLandmarkType.ringTip,
          HandLandmarkType.ringPip,
          HandLandmarkType.ringMcp,
        );
      case Finger.pinky:
        return _isFingerExtendedByTip(
          HandLandmarkType.pinkyTip,
          HandLandmarkType.pinkyPip,
          HandLandmarkType.pinkyMcp,
        );
    }
  }

  bool _isFingerExtendedByTip(
    HandLandmarkType tipType,
    HandLandmarkType pipType,
    HandLandmarkType mcpType,
  ) {
    final tip = getLandmark(tipType);
    final pip = getLandmark(pipType);
    final mcp = getLandmark(mcpType);
    if (tip == null || pip == null || mcp == null) return false;
    
    // Un dedo está extendido si la punta está más arriba (menor Y) que PIP
    // y PIP está más arriba que MCP
    return tip.y < pip.y && pip.y < mcp.y;
  }

  /// Contar dedos extendidos
  int get extendedFingersCount {
    int count = 0;
    for (final finger in Finger.values) {
      if (isFingerExtended(finger)) count++;
    }
    return count;
  }

  /// Calcular ángulo entre tres puntos
  double angleBetween(HandLandmarkType a, HandLandmarkType b, HandLandmarkType c) {
    final pointA = getLandmark(a);
    final pointB = getLandmark(b);
    final pointC = getLandmark(c);
    
    if (pointA == null || pointB == null || pointC == null) return 0;
    
    final ba = math.Point(pointA.x - pointB.x, pointA.y - pointB.y);
    final bc = math.Point(pointC.x - pointB.x, pointC.y - pointB.y);
    
    final dotProduct = ba.x * bc.x + ba.y * bc.y;
    final magnitudeBA = math.sqrt(ba.x * ba.x + ba.y * ba.y);
    final magnitudeBC = math.sqrt(bc.x * bc.x + bc.y * bc.y);
    
    if (magnitudeBA == 0 || magnitudeBC == 0) return 0;
    
    final cosAngle = dotProduct / (magnitudeBA * magnitudeBC);
    return math.acos(cosAngle.clamp(-1.0, 1.0)) * 180 / math.pi;
  }

  factory HandDetectionResult.fromJson(Map<String, dynamic> json) {
    return HandDetectionResult(
      landmarks: (json['landmarks'] as List?)
          ?.map((l) => HandLandmark.fromJson(l))
          .toList() ?? [],
      handedness: Handedness.fromString(json['handedness'] ?? 'right'),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'landmarks': landmarks.map((l) => l.toJson()).toList(),
    'handedness': handedness.value,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  List<Object?> get props => [landmarks, handedness, confidence, timestamp];
}

/// Lateralidad de la mano
enum Handedness {
  left('left', 'Izquierda'),
  right('right', 'Derecha');

  final String value;
  final String displayName;
  const Handedness(this.value, this.displayName);

  static Handedness fromString(String value) {
    return Handedness.values.firstWhere(
      (h) => h.value == value.toLowerCase(),
      orElse: () => Handedness.right,
    );
  }
}

/// Dedos de la mano
enum Finger { thumb, indexFinger, middle, ring, pinky }

/// Frame completo de detección (puede incluir dos manos)
class HandTrackingFrame extends Equatable {
  final List<HandDetectionResult> hands;
  final int frameNumber;
  final DateTime timestamp;
  final int processingTimeMs;

  const HandTrackingFrame({
    required this.hands,
    required this.frameNumber,
    required this.timestamp,
    this.processingTimeMs = 0,
  });

  bool get hasHands => hands.isNotEmpty;
  bool get hasTwoHands => hands.length >= 2;
  
  HandDetectionResult? get leftHand => hands.cast<HandDetectionResult?>().firstWhere(
    (h) => h?.handedness == Handedness.left,
    orElse: () => null,
  );
  
  HandDetectionResult? get rightHand => hands.cast<HandDetectionResult?>().firstWhere(
    (h) => h?.handedness == Handedness.right,
    orElse: () => null,
  );

  factory HandTrackingFrame.empty() {
    return HandTrackingFrame(
      hands: [],
      frameNumber: 0,
      timestamp: DateTime.now(),
    );
  }

  factory HandTrackingFrame.fromJson(Map<String, dynamic> json) {
    return HandTrackingFrame(
      hands: (json['hands'] as List?)
          ?.map((h) => HandDetectionResult.fromJson(h))
          .toList() ?? [],
      frameNumber: json['frame_number'] ?? 0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      processingTimeMs: json['processing_time_ms'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [hands, frameNumber, timestamp, processingTimeMs];
}
