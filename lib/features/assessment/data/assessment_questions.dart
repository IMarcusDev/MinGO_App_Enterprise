import '../domain/entities/assessment_entities.dart';

/// Banco de preguntas de la prueba de conocimiento
/// Basado en el Anexo 3 del SRS
class AssessmentQuestions {
  static const List<AssessmentQuestion> questions = [
    // Pregunta 1: Conocimiento básico de señas
    AssessmentQuestion(
      id: 1,
      category: 'Conocimiento básico de señas',
      question: '¿Conoce alguna seña básica de saludo (ej. "Hola", "Gracias")?',
      options: [
        AssessmentOption(text: 'Sí', score: 5),
        AssessmentOption(text: 'Algo', score: 3),
        AssessmentOption(text: 'No', score: 0),
      ],
    ),

    // Pregunta 2: Edad del hijo/hija (se maneja diferente - campo numérico)
    // Esta pregunta se muestra como slider o input numérico

    // Pregunta 3: Estrategias de comunicación
    AssessmentQuestion(
      id: 3,
      category: 'Estrategias de comunicación',
      question: '¿Ha usado imágenes o gestos para comunicarse con su hijo(a)?',
      options: [
        AssessmentOption(text: 'Frecuentemente', score: 5),
        AssessmentOption(text: 'A veces', score: 3),
        AssessmentOption(text: 'Nunca', score: 0),
      ],
    ),

    // Pregunta 4: Lenguaje inclusivo
    AssessmentQuestion(
      id: 4,
      category: 'Lenguaje inclusivo',
      question: '¿Conoce qué es la Lengua de Señas Ecuatoriana (LSEC)?',
      options: [
        AssessmentOption(text: 'Sí', score: 5),
        AssessmentOption(text: 'He escuchado, pero no la uso', score: 3),
        AssessmentOption(text: 'No', score: 0),
      ],
    ),

    // Pregunta 5: Práctica previa
    AssessmentQuestion(
      id: 5,
      category: 'Práctica previa',
      question: '¿Ha intentado enseñar alguna seña a su hijo(a) anteriormente?',
      options: [
        AssessmentOption(text: 'Sí', score: 5),
        AssessmentOption(text: 'Lo intento, pero no sé cómo', score: 3),
        AssessmentOption(text: 'No', score: 0),
      ],
    ),

    // Pregunta 6: Recursos utilizados
    AssessmentQuestion(
      id: 6,
      category: 'Recursos utilizados',
      question: '¿Ha consultado libros, videos o tutoriales sobre señas?',
      options: [
        AssessmentOption(text: 'Sí', score: 5),
        AssessmentOption(text: 'Solo videos', score: 3),
        AssessmentOption(text: 'Solo libros', score: 3),
        AssessmentOption(text: 'No', score: 0),
      ],
    ),

    // Pregunta 7: Entorno
    AssessmentQuestion(
      id: 7,
      category: 'Recursos utilizados',
      question: '¿Alguien más en su entorno conoce acerca de la lengua de señas?',
      options: [
        AssessmentOption(text: 'Sí, varios', score: 5),
        AssessmentOption(text: 'Solo una persona', score: 3),
        AssessmentOption(text: 'No lo sé', score: 1),
        AssessmentOption(text: 'Nadie', score: 0),
      ],
    ),

    // Pregunta 8: Dificultades actuales
    AssessmentQuestion(
      id: 8,
      category: 'Dificultades actuales',
      question: '¿Considera que tiene dificultades para comprender gestos?',
      options: [
        AssessmentOption(text: 'No', score: 5),
        AssessmentOption(text: 'A veces', score: 3),
        AssessmentOption(text: 'No lo he intentado', score: 1),
        AssessmentOption(text: 'Sí', score: 0),
      ],
    ),

    // Pregunta 9: Experiencia educativa previa
    AssessmentQuestion(
      id: 9,
      category: 'Experiencia educativa previa',
      question: '¿Ha participado antes en cursos o talleres sobre LSEC?',
      options: [
        AssessmentOption(text: 'Sí', score: 5),
        AssessmentOption(text: 'De manera informal', score: 3),
        AssessmentOption(text: 'No', score: 0),
      ],
    ),

    // Pregunta 10: Accesibilidad tecnológica
    AssessmentQuestion(
      id: 10,
      category: 'Accesibilidad tecnológica',
      question: '¿Tiene acceso a un dispositivo con cámara y audio funcional?',
      options: [
        AssessmentOption(text: 'Sí', score: 5),
        AssessmentOption(text: 'Parcial (solo cámara o solo audio)', score: 3),
        AssessmentOption(text: 'No', score: 0),
      ],
      helpText: 'Esto es importante para las prácticas interactivas con cámara.',
    ),
  ];

  /// Puntaje máximo posible (sin contar la pregunta de edad)
  static const int maxScore = 45;

  /// Obtener nivel según puntaje
  static String getLevelFromScore(int score) {
    if (score <= 15) return 'Principiante';
    if (score <= 30) return 'Intermedio';
    return 'Avanzado';
  }

  /// Obtener mensaje motivacional según nivel
  static String getMotivationalMessage(String level) {
    switch (level) {
      case 'Principiante':
        return '¡Bienvenido al mundo de las señas! Comenzaremos desde lo básico para que aprendas junto a tu hijo(a).';
      case 'Intermedio':
        return '¡Excelente! Ya tienes conocimientos previos. Te ayudaremos a fortalecer y ampliar tu vocabulario.';
      case 'Avanzado':
        return '¡Impresionante! Tienes una buena base. Perfeccionaremos tus habilidades con contenido avanzado.';
      default:
        return '¡Comencemos tu viaje de aprendizaje!';
    }
  }

  /// Obtener categoría de edad
  static String getAgeCategory(int age) {
    if (age <= 3) return '1 a 3 años';
    if (age <= 5) return '3 a 5 años';
    return '5 a 12 años';
  }

  /// Obtener descripción de la categoría de edad
  static String getAgeCategoryDescription(int age) {
    if (age <= 3) {
      return 'Contenido enfocado en señas básicas, colores, animales y objetos cotidianos.';
    }
    if (age <= 5) {
      return 'Contenido con vocabulario más amplio, acciones, emociones y frases simples.';
    }
    return 'Contenido avanzado con frases compuestas, gramática de LSEC y conversaciones.';
  }
}
