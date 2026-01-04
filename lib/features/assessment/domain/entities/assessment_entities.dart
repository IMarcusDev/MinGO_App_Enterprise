import 'package:equatable/equatable.dart';

/// Pregunta de la prueba de conocimiento
class AssessmentQuestion extends Equatable {
  final int id;
  final String category;
  final String question;
  final List<AssessmentOption> options;
  final String? helpText;

  const AssessmentQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    this.helpText,
  });

  @override
  List<Object?> get props => [id, category, question, options, helpText];
}

/// Opción de respuesta con puntaje
class AssessmentOption extends Equatable {
  final String text;
  final int score;

  const AssessmentOption({
    required this.text,
    required this.score,
  });

  @override
  List<Object?> get props => [text, score];
}

/// Respuesta del usuario a una pregunta
class AssessmentAnswer extends Equatable {
  final int questionId;
  final int selectedOptionIndex;
  final int score;

  const AssessmentAnswer({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.score,
  });

  @override
  List<Object?> get props => [questionId, selectedOptionIndex, score];
}

/// Resultado de la prueba de conocimiento
class AssessmentResult extends Equatable {
  final int totalScore;
  final int maxPossibleScore;
  final String assignedLevel;
  final int childAge;
  final String ageCategory;
  final DateTime completedAt;
  final List<AssessmentAnswer> answers;

  const AssessmentResult({
    required this.totalScore,
    required this.maxPossibleScore,
    required this.assignedLevel,
    required this.childAge,
    required this.ageCategory,
    required this.completedAt,
    required this.answers,
  });

  double get percentage => (totalScore / maxPossibleScore) * 100;

  @override
  List<Object?> get props => [
        totalScore,
        maxPossibleScore,
        assignedLevel,
        childAge,
        ageCategory,
        completedAt,
        answers,
      ];
}

/// Niveles de conocimiento
enum KnowledgeLevel {
  principiante(0, 15, 'Principiante'),
  intermedio(16, 30, 'Intermedio'),
  avanzado(31, 45, 'Avanzado');

  final int minScore;
  final int maxScore;
  final String displayName;

  const KnowledgeLevel(this.minScore, this.maxScore, this.displayName);

  static KnowledgeLevel fromScore(int score) {
    if (score <= 15) return KnowledgeLevel.principiante;
    if (score <= 30) return KnowledgeLevel.intermedio;
    return KnowledgeLevel.avanzado;
  }
}

/// Categorías de edad del niño
enum AgeCategory {
  toddler(1, 3, '1 a 3 años'),
  preschool(3, 5, '3 a 5 años'),
  school(5, 12, '5 a 12 años');

  final int minAge;
  final int maxAge;
  final String displayName;

  const AgeCategory(this.minAge, this.maxAge, this.displayName);

  static AgeCategory fromAge(int age) {
    if (age <= 3) return AgeCategory.toddler;
    if (age <= 5) return AgeCategory.preschool;
    return AgeCategory.school;
  }
}
