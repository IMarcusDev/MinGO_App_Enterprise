import 'dart:math' as math;

import 'package:mingo/features/hand_tracking/domain/entities/hand_landmark_entities.dart';
import 'package:mingo/features/hand_tracking/domain/entities/sign_template_entities.dart';


/// Servicio para comparar poses de mano con plantillas de señas
class SignComparisonService {
  static const double _matchThreshold = 0.75; // 75% para considerar match
  static const double _touchingThreshold = 0.05; // Distancia para "tocándose"

  /// Comparar una detección de mano con una plantilla de seña
  SignMatchResult compareWithTemplate(
    HandDetectionResult detection,
    SignTemplate template,
  ) {
    if (detection.landmarks.isEmpty || template.poses.isEmpty) {
      return SignMatchResult.noMatch(template);
    }

    // Para señas estáticas, comparar con la única pose
    // Para señas dinámicas, esto debería ser parte de un análisis temporal
    final pose = template.poses.first;
    
    // Calcular score de dedos
    final fingerScores = _calculateFingerScores(detection, pose);
    
    // Calcular score de orientación
    final orientationScore = pose.orientation != null
        ? _calculateOrientationScore(detection, pose.orientation!)
        : 1.0;
    
    // Calcular score de restricciones
    final constraintScore = _calculateConstraintScore(detection, pose.constraints);
    
    // Score general ponderado
    final fingerAvg = fingerScores.values.isEmpty 
        ? 0.0 
        : fingerScores.values.reduce((a, b) => a + b) / fingerScores.values.length;
    
    final overallScore = (fingerAvg * 0.6) + 
                         (orientationScore * 0.2) + 
                         (constraintScore * 0.2);
    
    // Generar feedback
    final feedback = _generateFeedback(fingerScores, orientationScore, constraintScore, pose);
    
    return SignMatchResult(
      template: template,
      overallScore: overallScore,
      fingerScores: fingerScores,
      orientationScore: orientationScore,
      constraintScore: constraintScore,
      feedback: feedback,
      isMatch: overallScore >= _matchThreshold,
    );
  }

  /// Calcular scores para cada dedo
  Map<Finger, double> _calculateFingerScores(
    HandDetectionResult detection,
    HandPoseTemplate pose,
  ) {
    final scores = <Finger, double>{};
    
    for (final fingerState in pose.fingerStates) {
      final finger = fingerState.finger;
      final expectedPosition = fingerState.position;
      
      if (expectedPosition == FingerPosition.any) {
        scores[finger] = 1.0;
        continue;
      }
      
      final isExtended = detection.isFingerExtended(finger);
      
      switch (expectedPosition) {
        case FingerPosition.extended:
          scores[finger] = isExtended ? 1.0 : 0.0;
          break;
        case FingerPosition.closed:
          scores[finger] = !isExtended ? 1.0 : 0.0;
          break;
        case FingerPosition.bent:
          // Para "doblado", verificamos un estado intermedio
          scores[finger] = _calculateBentScore(detection, finger);
          break;
        case FingerPosition.any:
          scores[finger] = 1.0;
          break;
      }
      
      // Ajustar por ángulo si se especifica
      if (fingerState.minAngle != null || fingerState.maxAngle != null) {
        final angleScore = _calculateAngleScore(detection, finger, fingerState);
        scores[finger] = (scores[finger]! + angleScore) / 2;
      }
    }
    
    return scores;
  }

  /// Calcular score para dedo doblado
  double _calculateBentScore(HandDetectionResult detection, Finger finger) {
    // Un dedo está "doblado" si no está ni completamente extendido ni cerrado
    // Esto se puede estimar por el ángulo del dedo
    
    HandLandmarkType mcpType, pipType, tipType;
    
    switch (finger) {
      case Finger.thumb:
        return 0.5; // Pulgar tiene diferente mecánica
      case Finger.indexFinger:
        mcpType = HandLandmarkType.indexMcp;
        pipType = HandLandmarkType.indexPip;
        tipType = HandLandmarkType.indexTip;
        break;
      case Finger.middle:
        mcpType = HandLandmarkType.middleMcp;
        pipType = HandLandmarkType.middlePip;
        tipType = HandLandmarkType.middleTip;
        break;
      case Finger.ring:
        mcpType = HandLandmarkType.ringMcp;
        pipType = HandLandmarkType.ringPip;
        tipType = HandLandmarkType.ringTip;
        break;
      case Finger.pinky:
        mcpType = HandLandmarkType.pinkyMcp;
        pipType = HandLandmarkType.pinkyPip;
        tipType = HandLandmarkType.pinkyTip;
        break;
    }
    
    final angle = detection.angleBetween(mcpType, pipType, tipType);
    
    // Ángulo ideal para "doblado" es ~90-120 grados
    if (angle >= 80 && angle <= 130) {
      return 1.0;
    } else if (angle >= 60 && angle <= 150) {
      return 0.7;
    } else {
      return 0.3;
    }
  }

  /// Calcular score basado en ángulo especificado
  double _calculateAngleScore(
    HandDetectionResult detection,
    Finger finger,
    FingerState fingerState,
  ) {
    // Obtener landmarks del dedo
    HandLandmarkType mcpType, pipType, tipType;
    
    switch (finger) {
      case Finger.thumb:
        mcpType = HandLandmarkType.thumbMcp;
        pipType = HandLandmarkType.thumbIp;
        tipType = HandLandmarkType.thumbTip;
        break;
      case Finger.indexFinger:
        mcpType = HandLandmarkType.indexMcp;
        pipType = HandLandmarkType.indexPip;
        tipType = HandLandmarkType.indexTip;
        break;
      case Finger.middle:
        mcpType = HandLandmarkType.middleMcp;
        pipType = HandLandmarkType.middlePip;
        tipType = HandLandmarkType.middleTip;
        break;
      case Finger.ring:
        mcpType = HandLandmarkType.ringMcp;
        pipType = HandLandmarkType.ringPip;
        tipType = HandLandmarkType.ringTip;
        break;
      case Finger.pinky:
        mcpType = HandLandmarkType.pinkyMcp;
        pipType = HandLandmarkType.pinkyPip;
        tipType = HandLandmarkType.pinkyTip;
        break;
    }
    
    final angle = detection.angleBetween(mcpType, pipType, tipType);
    
    final minAngle = fingerState.minAngle ?? 0;
    final maxAngle = fingerState.maxAngle ?? 180;
    
    if (angle >= minAngle && angle <= maxAngle) {
      return 1.0;
    }
    
    // Score parcial si está cerca del rango
    final distanceToRange = angle < minAngle 
        ? minAngle - angle 
        : angle - maxAngle;
    
    return math.max(0, 1 - (distanceToRange / 45)); // Penalizar por cada 45 grados fuera
  }

  /// Calcular score de orientación
  double _calculateOrientationScore(
    HandDetectionResult detection,
    HandOrientation expectedOrientation,
  ) {
    // Determinar orientación basada en la posición relativa de landmarks clave
    final wrist = detection.getLandmark(HandLandmarkType.wrist);
    final middleMcp = detection.getLandmark(HandLandmarkType.middleMcp);
    final indexMcp = detection.getLandmark(HandLandmarkType.indexMcp);
    final pinkyMcp = detection.getLandmark(HandLandmarkType.pinkyMcp);
    
    if (wrist == null || middleMcp == null || indexMcp == null || pinkyMcp == null) {
      return 0.5; // Score neutro si faltan landmarks
    }
    
    // Calcular vectores para determinar orientación
    final palmNormalZ = middleMcp.z - wrist.z;
    final palmNormalY = middleMcp.y - wrist.y;
    
    // Simplificación: usar coordenada Z para determinar si palma está al frente
    HandOrientation detectedOrientation;
    
    if (palmNormalZ < -0.1) {
      detectedOrientation = HandOrientation.palmForward;
    } else if (palmNormalZ > 0.1) {
      detectedOrientation = HandOrientation.palmBack;
    } else if (palmNormalY < -0.1) {
      detectedOrientation = HandOrientation.palmUp;
    } else if (palmNormalY > 0.1) {
      detectedOrientation = HandOrientation.palmDown;
    } else {
      // Usar posición horizontal para izquierda/derecha
      final horizontalDiff = indexMcp.x - pinkyMcp.x;
      if (horizontalDiff > 0.1) {
        detectedOrientation = HandOrientation.palmRight;
      } else if (horizontalDiff < -0.1) {
        detectedOrientation = HandOrientation.palmLeft;
      } else {
        detectedOrientation = HandOrientation.palmForward;
      }
    }
    
    return detectedOrientation == expectedOrientation ? 1.0 : 0.3;
  }

  /// Calcular score de restricciones
  double _calculateConstraintScore(
    HandDetectionResult detection,
    List<LandmarkConstraint> constraints,
  ) {
    if (constraints.isEmpty) return 1.0;
    
    double totalScore = 0;
    
    for (final constraint in constraints) {
      final landmark1 = detection.getLandmark(constraint.landmark1);
      final landmark2 = detection.getLandmark(constraint.landmark2);
      
      if (landmark1 == null || landmark2 == null) {
        totalScore += 0.5;
        continue;
      }
      
      switch (constraint.type) {
        case ConstraintType.touching:
          final distance = landmark1.distance2DTo(landmark2);
          totalScore += distance < _touchingThreshold ? 1.0 : 0.0;
          break;
          
        case ConstraintType.distance:
          final distance = landmark1.distance2DTo(landmark2);
          final minDist = constraint.minValue ?? 0;
          final maxDist = constraint.maxValue ?? 1;
          totalScore += (distance >= minDist && distance <= maxDist) ? 1.0 : 0.3;
          break;
          
        case ConstraintType.above:
          totalScore += landmark1.y < landmark2.y ? 1.0 : 0.0;
          break;
          
        case ConstraintType.below:
          totalScore += landmark1.y > landmark2.y ? 1.0 : 0.0;
          break;
      }
    }
    
    return totalScore / constraints.length;
  }

  /// Generar feedback para el usuario
  List<String> _generateFeedback(
    Map<Finger, double> fingerScores,
    double orientationScore,
    double constraintScore,
    HandPoseTemplate pose,
  ) {
    final feedback = <String>[];
    
    // Feedback por dedos
    final fingerNames = {
      Finger.thumb: 'pulgar',
      Finger.indexFinger: 'índice',
      Finger.middle: 'medio',
      Finger.ring: 'anular',
      Finger.pinky: 'meñique',
    };
    
    for (final entry in fingerScores.entries) {
      if (entry.value < 0.5) {
        final fingerState = pose.fingerStates.firstWhere(
          (fs) => fs.finger == entry.key,
          orElse: () => FingerState(finger: entry.key, position: FingerPosition.any),
        );
        
        final fingerName = fingerNames[entry.key] ?? entry.key.name;
        
        switch (fingerState.position) {
          case FingerPosition.extended:
            feedback.add('Extiende más el dedo $fingerName');
            break;
          case FingerPosition.closed:
            feedback.add('Cierra más el dedo $fingerName');
            break;
          case FingerPosition.bent:
            feedback.add('Dobla ligeramente el dedo $fingerName');
            break;
          case FingerPosition.any:
            break;
        }
      }
    }
    
    // Feedback de orientación
    if (orientationScore < 0.5 && pose.orientation != null) {
      feedback.add('Ajusta la orientación: ${pose.orientation!.displayName}');
    }
    
    // Feedback general
    if (feedback.isEmpty) {
      final avgScore = fingerScores.values.isEmpty 
          ? 0.0 
          : fingerScores.values.reduce((a, b) => a + b) / fingerScores.values.length;
      if (avgScore >= 0.9) {
        feedback.add('¡Perfecto! Mantén la posición');
      } else if (avgScore >= 0.75) {
        feedback.add('¡Muy bien! Pequeños ajustes');
      }
    }
    
    return feedback;
  }

  /// Detectar gesto básico (sin plantilla)
  BasicGesture detectBasicGesture(HandDetectionResult detection) {
    if (detection.landmarks.isEmpty) return BasicGesture.none;
    
    final extendedCount = detection.extendedFingersCount;
    
    // Puño cerrado
    if (detection.isClosedFist) return BasicGesture.fist;
    
    // Mano abierta
    if (detection.isOpenHand) return BasicGesture.openHand;
    
    // Un dedo (índice)
    if (extendedCount == 1 && detection.isFingerExtended(Finger.indexFinger)) {
      return BasicGesture.pointingUp;
    }

    // Dos dedos (paz/victoria)
    if (extendedCount == 2 &&
        detection.isFingerExtended(Finger.indexFinger) &&
        detection.isFingerExtended(Finger.middle)) {
      return BasicGesture.peace;
    }
    
    // Pulgar arriba
    if (extendedCount == 1 && detection.isFingerExtended(Finger.thumb)) {
      return BasicGesture.thumbsUp;
    }
    
    // OK (pulgar e índice tocándose)
    final thumbTip = detection.getLandmark(HandLandmarkType.thumbTip);
    final indexTip = detection.getLandmark(HandLandmarkType.indexTip);
    if (thumbTip != null && indexTip != null) {
      if (thumbTip.distance2DTo(indexTip) < _touchingThreshold) {
        return BasicGesture.ok;
      }
    }
    
    // Rock (índice y meñique)
    if (extendedCount == 2 &&
        detection.isFingerExtended(Finger.indexFinger) &&
        detection.isFingerExtended(Finger.pinky)) {
      return BasicGesture.rock;
    }
    
    return BasicGesture.unknown;
  }
}

/// Gestos básicos reconocibles
enum BasicGesture {
  none('Ninguno', '❓'),
  fist('Puño', '✊'),
  openHand('Mano abierta', '✋'),
  pointingUp('Señalando', '☝️'),
  peace('Paz', '✌️'),
  thumbsUp('Pulgar arriba', '👍'),
  ok('OK', '👌'),
  rock('Rock', '🤘'),
  unknown('Desconocido', '❓');

  final String name;
  final String emoji;
  const BasicGesture(this.name, this.emoji);
}
