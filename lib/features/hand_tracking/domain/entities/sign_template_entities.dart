import 'package:equatable/equatable.dart';
import 'hand_landmark_entities.dart';

/// Plantilla de una seña (pose de referencia)
class SignTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final SignDifficulty difficulty;
  final List<HandPoseTemplate> poses; // Puede tener múltiples poses (seña dinámica)
  final bool requiresTwoHands;
  final String? videoUrl;
  final String? imageUrl;
  final List<String> keywords;

  const SignTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.poses,
    this.requiresTwoHands = false,
    this.videoUrl,
    this.imageUrl,
    this.keywords = const [],
  });

  bool get isStatic => poses.length == 1;
  bool get isDynamic => poses.length > 1;

  factory SignTemplate.fromJson(Map<String, dynamic> json) {
    return SignTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      difficulty: SignDifficulty.fromString(json['difficulty'] ?? 'beginner'),
      poses: (json['poses'] as List?)
          ?.map((p) => HandPoseTemplate.fromJson(p))
          .toList() ?? [],
      requiresTwoHands: json['requires_two_hands'] ?? false,
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'difficulty': difficulty.value,
    'poses': poses.map((p) => p.toJson()).toList(),
    'requires_two_hands': requiresTwoHands,
    'video_url': videoUrl,
    'image_url': imageUrl,
    'keywords': keywords,
  };

  @override
  List<Object?> get props => [id, name, category, difficulty, poses];
}

/// Dificultad de la seña
enum SignDifficulty {
  beginner('beginner', 'Principiante', 1),
  intermediate('intermediate', 'Intermedio', 2),
  advanced('advanced', 'Avanzado', 3);

  final String value;
  final String displayName;
  final int level;
  const SignDifficulty(this.value, this.displayName, this.level);

  static SignDifficulty fromString(String value) {
    return SignDifficulty.values.firstWhere(
      (d) => d.value == value.toLowerCase(),
      orElse: () => SignDifficulty.beginner,
    );
  }
}

/// Plantilla de pose de mano (para una seña estática o un frame de seña dinámica)
class HandPoseTemplate extends Equatable {
  final int order; // Orden en la secuencia (para señas dinámicas)
  final List<FingerState> fingerStates;
  final HandOrientation? orientation;
  final List<LandmarkConstraint> constraints;
  final double holdDurationMs; // Tiempo mínimo a mantener la pose

  const HandPoseTemplate({
    this.order = 0,
    required this.fingerStates,
    this.orientation,
    this.constraints = const [],
    this.holdDurationMs = 500,
  });

  factory HandPoseTemplate.fromJson(Map<String, dynamic> json) {
    return HandPoseTemplate(
      order: json['order'] ?? 0,
      fingerStates: (json['finger_states'] as List?)
          ?.map((f) => FingerState.fromJson(f))
          .toList() ?? [],
      orientation: json['orientation'] != null
          ? HandOrientation.fromString(json['orientation'])
          : null,
      constraints: (json['constraints'] as List?)
          ?.map((c) => LandmarkConstraint.fromJson(c))
          .toList() ?? [],
      holdDurationMs: (json['hold_duration_ms'] ?? 500).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'order': order,
    'finger_states': fingerStates.map((f) => f.toJson()).toList(),
    'orientation': orientation?.value,
    'constraints': constraints.map((c) => c.toJson()).toList(),
    'hold_duration_ms': holdDurationMs,
  };

  @override
  List<Object?> get props => [order, fingerStates, orientation, constraints];
}

/// Estado de un dedo en la plantilla
class FingerState extends Equatable {
  final Finger finger;
  final FingerPosition position;
  final double? minAngle; // Ángulo mínimo de flexión
  final double? maxAngle; // Ángulo máximo de flexión

  const FingerState({
    required this.finger,
    required this.position,
    this.minAngle,
    this.maxAngle,
  });

  factory FingerState.fromJson(Map<String, dynamic> json) {
    return FingerState(
      finger: Finger.values.firstWhere(
        (f) => f.name == json['finger'],
        orElse: () => Finger.indexFinger,
      ),
      position: FingerPosition.fromString(json['position'] ?? 'extended'),
      minAngle: json['min_angle']?.toDouble(),
      maxAngle: json['max_angle']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'finger': finger.name,
    'position': position.value,
    'min_angle': minAngle,
    'max_angle': maxAngle,
  };

  @override
  List<Object?> get props => [finger, position, minAngle, maxAngle];
}

/// Posición del dedo
enum FingerPosition {
  extended('extended', 'Extendido'),
  bent('bent', 'Doblado'),
  closed('closed', 'Cerrado'),
  any('any', 'Cualquiera');

  final String value;
  final String displayName;
  const FingerPosition(this.value, this.displayName);

  static FingerPosition fromString(String value) {
    return FingerPosition.values.firstWhere(
      (p) => p.value == value.toLowerCase(),
      orElse: () => FingerPosition.any,
    );
  }
}

/// Orientación de la mano
enum HandOrientation {
  palmForward('palm_forward', 'Palma al frente'),
  palmBack('palm_back', 'Dorso al frente'),
  palmDown('palm_down', 'Palma abajo'),
  palmUp('palm_up', 'Palma arriba'),
  palmLeft('palm_left', 'Palma a la izquierda'),
  palmRight('palm_right', 'Palma a la derecha');

  final String value;
  final String displayName;
  const HandOrientation(this.value, this.displayName);

  static HandOrientation fromString(String value) {
    return HandOrientation.values.firstWhere(
      (o) => o.value == value.toLowerCase(),
      orElse: () => HandOrientation.palmForward,
    );
  }
}

/// Restricción entre landmarks (para poses complejas)
class LandmarkConstraint extends Equatable {
  final HandLandmarkType landmark1;
  final HandLandmarkType landmark2;
  final ConstraintType type;
  final double? minValue;
  final double? maxValue;

  const LandmarkConstraint({
    required this.landmark1,
    required this.landmark2,
    required this.type,
    this.minValue,
    this.maxValue,
  });

  factory LandmarkConstraint.fromJson(Map<String, dynamic> json) {
    return LandmarkConstraint(
      landmark1: HandLandmarkType.values[json['landmark1'] ?? 0],
      landmark2: HandLandmarkType.values[json['landmark2'] ?? 0],
      type: ConstraintType.fromString(json['type'] ?? 'distance'),
      minValue: json['min_value']?.toDouble(),
      maxValue: json['max_value']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'landmark1': landmark1.index,
    'landmark2': landmark2.index,
    'type': type.value,
    'min_value': minValue,
    'max_value': maxValue,
  };

  @override
  List<Object?> get props => [landmark1, landmark2, type, minValue, maxValue];
}

/// Tipo de restricción
enum ConstraintType {
  distance('distance', 'Distancia'),
  touching('touching', 'Tocándose'),
  above('above', 'Encima de'),
  below('below', 'Debajo de');

  final String value;
  final String displayName;
  const ConstraintType(this.value, this.displayName);

  static ConstraintType fromString(String value) {
    return ConstraintType.values.firstWhere(
      (c) => c.value == value.toLowerCase(),
      orElse: () => ConstraintType.distance,
    );
  }
}

/// Resultado de comparación entre pose detectada y plantilla
class SignMatchResult extends Equatable {
  final SignTemplate template;
  final double overallScore; // 0.0 - 1.0
  final Map<Finger, double> fingerScores; // Score por dedo
  final double orientationScore;
  final double constraintScore;
  final List<String> feedback; // Consejos de mejora
  final bool isMatch; // >= umbral de aceptación

  const SignMatchResult({
    required this.template,
    required this.overallScore,
    required this.fingerScores,
    required this.orientationScore,
    required this.constraintScore,
    required this.feedback,
    required this.isMatch,
  });

  /// Porcentaje de similitud
  int get scorePercent => (overallScore * 100).round();

  /// Nivel de coincidencia
  MatchLevel get matchLevel {
    if (overallScore >= 0.9) return MatchLevel.excellent;
    if (overallScore >= 0.75) return MatchLevel.good;
    if (overallScore >= 0.5) return MatchLevel.partial;
    return MatchLevel.poor;
  }

  factory SignMatchResult.noMatch(SignTemplate template) {
    return SignMatchResult(
      template: template,
      overallScore: 0,
      fingerScores: {},
      orientationScore: 0,
      constraintScore: 0,
      feedback: ['No se detectó la mano'],
      isMatch: false,
    );
  }

  @override
  List<Object?> get props => [
    template, overallScore, fingerScores, orientationScore, constraintScore, isMatch
  ];
}

/// Nivel de coincidencia
enum MatchLevel {
  excellent('¡Excelente!', '🌟'),
  good('¡Muy bien!', '⭐'),
  partial('Casi...', '👍'),
  poor('Sigue intentando', '💪');

  final String message;
  final String emoji;
  const MatchLevel(this.message, this.emoji);
}

/// Sesión de práctica de señas
class PracticeSession extends Equatable {
  final String id;
  final String signId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<PracticeAttempt> attempts;
  final bool completed;

  const PracticeSession({
    required this.id,
    required this.signId,
    required this.startTime,
    this.endTime,
    this.attempts = const [],
    this.completed = false,
  });

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
  int get successfulAttempts => attempts.where((a) => a.isSuccess).length;
  double get successRate => attempts.isEmpty ? 0 : successfulAttempts / attempts.length;
  double get bestScore => attempts.isEmpty ? 0 : 
      attempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [id, signId, startTime, endTime, attempts, completed];
}

/// Intento de práctica individual
class PracticeAttempt extends Equatable {
  final int attemptNumber;
  final DateTime timestamp;
  final double score;
  final List<String> feedback;
  final int holdTimeMs;

  const PracticeAttempt({
    required this.attemptNumber,
    required this.timestamp,
    required this.score,
    required this.feedback,
    required this.holdTimeMs,
  });

  bool get isSuccess => score >= 0.75;

  @override
  List<Object?> get props => [attemptNumber, timestamp, score, holdTimeMs];
}
