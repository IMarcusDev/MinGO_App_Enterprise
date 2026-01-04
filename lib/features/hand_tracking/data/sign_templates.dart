import '../domain/entities/hand_landmark_entities.dart';
import '../domain/entities/sign_template_entities.dart';

/// Plantillas de señas básicas para Lengua de Señas Ecuatoriana (LSEC)
/// Estas son aproximaciones que deberán ajustarse con datos reales
class SignTemplates {
  /// Obtener todas las plantillas disponibles
  static List<SignTemplate> get all => [
    ...alphabet,
    ...basicSigns,
    ...greetings,
    ...numbers,
  ];

  /// Obtener plantillas por categoría
  static List<SignTemplate> getByCategory(String category) {
    return all.where((s) => s.category == category).toList();
  }

  /// Obtener plantillas por dificultad
  static List<SignTemplate> getByDifficulty(SignDifficulty difficulty) {
    return all.where((s) => s.difficulty == difficulty).toList();
  }

  // ============================================
  // ALFABETO MANUAL (Dactilología)
  // ============================================
  
  static List<SignTemplate> get alphabet => [
    // Letra A - Puño con pulgar al lado
    SignTemplate(
      id: 'letra_a',
      name: 'A',
      description: 'Puño cerrado con el pulgar al costado',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.closed),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
          orientation: HandOrientation.palmForward,
        ),
      ],
      keywords: ['a', 'primera letra'],
    ),

    // Letra B - Dedos extendidos, pulgar cruzado
    SignTemplate(
      id: 'letra_b',
      name: 'B',
      description: 'Dedos juntos y extendidos, pulgar doblado sobre la palma',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
          orientation: HandOrientation.palmForward,
        ),
      ],
      keywords: ['b'],
    ),

    // Letra C - Mano en forma de C
    SignTemplate(
      id: 'letra_c',
      name: 'C',
      description: 'Mano curvada formando una C',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.bent),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.bent),
            FingerState(finger: Finger.middle, position: FingerPosition.bent),
            FingerState(finger: Finger.ring, position: FingerPosition.bent),
            FingerState(finger: Finger.pinky, position: FingerPosition.bent),
          ],
        ),
      ],
      keywords: ['c'],
    ),

    // Letra D - Índice arriba, otros cerrados formando círculo con pulgar
    SignTemplate(
      id: 'letra_d',
      name: 'D',
      description: 'Índice extendido, otros dedos forman círculo con pulgar',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.bent),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
          constraints: [
            LandmarkConstraint(
              landmark1: HandLandmarkType.thumbTip,
              landmark2: HandLandmarkType.middleTip,
              type: ConstraintType.touching,
            ),
          ],
        ),
      ],
      keywords: ['d'],
    ),

    // Letra E - Dedos doblados sobre pulgar
    SignTemplate(
      id: 'letra_e',
      name: 'E',
      description: 'Dedos doblados tocando el pulgar',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.bent),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.closed),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['e'],
    ),

    // Letra L - Índice y pulgar extendidos (forma de L)
    SignTemplate(
      id: 'letra_l',
      name: 'L',
      description: 'Índice y pulgar extendidos formando una L',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['l', 'ele'],
    ),

    // Letra O - Todos los dedos formando un círculo
    SignTemplate(
      id: 'letra_o',
      name: 'O',
      description: 'Dedos formando un círculo',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.bent),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.bent),
            FingerState(finger: Finger.middle, position: FingerPosition.bent),
            FingerState(finger: Finger.ring, position: FingerPosition.bent),
            FingerState(finger: Finger.pinky, position: FingerPosition.bent),
          ],
          constraints: [
            LandmarkConstraint(
              landmark1: HandLandmarkType.thumbTip,
              landmark2: HandLandmarkType.indexTip,
              type: ConstraintType.touching,
            ),
          ],
        ),
      ],
      keywords: ['o'],
    ),

    // Letra V - Índice y medio extendidos (victoria/paz)
    SignTemplate(
      id: 'letra_v',
      name: 'V',
      description: 'Índice y medio extendidos separados',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
          orientation: HandOrientation.palmForward,
        ),
      ],
      keywords: ['v', 'victoria', 'paz'],
    ),

    // Letra Y - Pulgar y meñique extendidos
    SignTemplate(
      id: 'letra_y',
      name: 'Y',
      description: 'Pulgar y meñique extendidos',
      category: 'Alfabeto',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.closed),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
        ),
      ],
      keywords: ['y', 'ye'],
    ),
  ];

  // ============================================
  // NÚMEROS
  // ============================================

  static List<SignTemplate> get numbers => [
    // 1 - Índice extendido
    SignTemplate(
      id: 'numero_1',
      name: '1',
      description: 'Índice extendido',
      category: 'Números',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['1', 'uno'],
    ),

    // 2 - Índice y medio extendidos
    SignTemplate(
      id: 'numero_2',
      name: '2',
      description: 'Índice y medio extendidos',
      category: 'Números',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['2', 'dos'],
    ),

    // 3 - Índice, medio y anular extendidos
    SignTemplate(
      id: 'numero_3',
      name: '3',
      description: 'Tres dedos extendidos',
      category: 'Números',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['3', 'tres'],
    ),

    // 4 - Cuatro dedos extendidos (sin pulgar)
    SignTemplate(
      id: 'numero_4',
      name: '4',
      description: 'Cuatro dedos extendidos',
      category: 'Números',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
        ),
      ],
      keywords: ['4', 'cuatro'],
    ),

    // 5 - Mano abierta
    SignTemplate(
      id: 'numero_5',
      name: '5',
      description: 'Mano completamente abierta',
      category: 'Números',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
        ),
      ],
      keywords: ['5', 'cinco'],
    ),
  ];

  // ============================================
  // SEÑAS BÁSICAS
  // ============================================

  static List<SignTemplate> get basicSigns => [
    // Sí - Puño moviéndose (simplificado a pose estática)
    SignTemplate(
      id: 'si',
      name: 'Sí',
      description: 'Puño cerrado moviéndose hacia abajo',
      category: 'Básico',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.closed),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['sí', 'afirmación', 'correcto'],
    ),

    // No - Índice y medio juntos moviéndose
    SignTemplate(
      id: 'no',
      name: 'No',
      description: 'Índice y medio juntos moviéndose de lado a lado',
      category: 'Básico',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.closed),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['no', 'negación'],
    ),

    // OK / Bien
    SignTemplate(
      id: 'bien',
      name: 'Bien / OK',
      description: 'Pulgar arriba',
      category: 'Básico',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.closed),
            FingerState(finger: Finger.middle, position: FingerPosition.closed),
            FingerState(finger: Finger.ring, position: FingerPosition.closed),
            FingerState(finger: Finger.pinky, position: FingerPosition.closed),
          ],
        ),
      ],
      keywords: ['bien', 'ok', 'bueno', 'correcto'],
    ),
  ];

  // ============================================
  // SALUDOS
  // ============================================

  static List<SignTemplate> get greetings => [
    // Hola - Mano abierta moviéndose
    SignTemplate(
      id: 'hola',
      name: 'Hola',
      description: 'Mano abierta moviéndose de lado a lado',
      category: 'Saludos',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
          orientation: HandOrientation.palmForward,
        ),
      ],
      keywords: ['hola', 'saludo', 'hi'],
    ),

    // Adiós
    SignTemplate(
      id: 'adios',
      name: 'Adiós',
      description: 'Mano abierta moviéndose de lado a lado (despedida)',
      category: 'Saludos',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
          orientation: HandOrientation.palmForward,
        ),
      ],
      keywords: ['adiós', 'chao', 'despedida', 'bye'],
    ),

    // Gracias
    SignTemplate(
      id: 'gracias',
      name: 'Gracias',
      description: 'Mano plana desde la barbilla hacia adelante',
      category: 'Saludos',
      difficulty: SignDifficulty.beginner,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
          orientation: HandOrientation.palmUp,
        ),
      ],
      keywords: ['gracias', 'agradecimiento'],
    ),

    // Por favor
    SignTemplate(
      id: 'por_favor',
      name: 'Por favor',
      description: 'Palma plana sobre el pecho moviéndose en círculo',
      category: 'Saludos',
      difficulty: SignDifficulty.intermediate,
      poses: [
        HandPoseTemplate(
          fingerStates: [
            FingerState(finger: Finger.thumb, position: FingerPosition.extended),
            FingerState(finger: Finger.indexFinger, position: FingerPosition.extended),
            FingerState(finger: Finger.middle, position: FingerPosition.extended),
            FingerState(finger: Finger.ring, position: FingerPosition.extended),
            FingerState(finger: Finger.pinky, position: FingerPosition.extended),
          ],
        ),
      ],
      keywords: ['por favor', 'porfavor', 'please'],
    ),
  ];

  // ============================================
  // CATEGORÍAS DISPONIBLES
  // ============================================

  static List<String> get categories => [
    'Alfabeto',
    'Números',
    'Básico',
    'Saludos',
    'Familia',
    'Colores',
    'Animales',
    'Comida',
    'Emociones',
  ];
}
