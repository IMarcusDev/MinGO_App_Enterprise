import 'package:equatable/equatable.dart';

/// Contenido de una seña (para VIDEO y PRACTICE)
class SignContent extends Equatable {
  final String id;
  final String activityId;
  final String word;
  final String? videoUrl;
  final String? imageUrl;
  final String? audioUrl;
  final String? description;

  const SignContent({
    required this.id,
    required this.activityId,
    required this.word,
    this.videoUrl,
    this.imageUrl,
    this.audioUrl,
    this.description,
  });

  @override
  List<Object?> get props => [id, activityId, word];
}

/// Opción de respuesta para quiz
class QuizOption extends Equatable {
  final String id;
  final String text;
  final String? imageUrl;
  final bool isCorrect;

  const QuizOption({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [id, text, isCorrect];
}

/// Pregunta de quiz
class QuizQuestion extends Equatable {
  final String id;
  final String activityId;
  final String question;
  final String? questionImageUrl;
  final String? questionVideoUrl;
  final List<QuizOption> options;
  final int orderIndex;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.activityId,
    required this.question,
    this.questionImageUrl,
    this.questionVideoUrl,
    required this.options,
    required this.orderIndex,
    required this.points,
  });

  QuizOption? get correctOption => options.where((o) => o.isCorrect).firstOrNull;

  @override
  List<Object?> get props => [id, activityId, question, orderIndex];
}

/// Par para juego de memoria/matching
class GamePair extends Equatable {
  final String id;
  final String word;
  final String? imageUrl;
  final String? videoUrl;

  const GamePair({
    required this.id,
    required this.word,
    this.imageUrl,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [id, word];
}

/// Contenido de juego
class GameContent extends Equatable {
  final String id;
  final String activityId;
  final GameType gameType;
  final List<GamePair> pairs;
  final int timeLimit; // en segundos
  final int points;

  const GameContent({
    required this.id,
    required this.activityId,
    required this.gameType,
    required this.pairs,
    required this.timeLimit,
    required this.points,
  });

  @override
  List<Object?> get props => [id, activityId, gameType];
}

enum GameType {
  memory('MEMORY'),
  matching('MATCHING'),
  dragDrop('DRAG_DROP');

  final String value;
  const GameType(this.value);

  static GameType fromString(String value) {
    return GameType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => GameType.matching,
    );
  }
}

/// Resultado de una actividad completada
class ActivityResult extends Equatable {
  final String activityId;
  final int score;
  final int maxScore;
  final int correctAnswers;
  final int totalQuestions;
  final Duration timeTaken;
  final bool passed;

  const ActivityResult({
    required this.activityId,
    required this.score,
    required this.maxScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTaken,
    required this.passed,
  });

  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions * 100 : 0;

  @override
  List<Object?> get props => [activityId, score, correctAnswers];
}

/// Datos completos de una actividad para renderizar
class ActivityData extends Equatable {
  final String activityId;
  final ActivityContentType type;
  final List<SignContent>? signContents;
  final List<QuizQuestion>? quizQuestions;
  final GameContent? gameContent;

  const ActivityData({
    required this.activityId,
    required this.type,
    this.signContents,
    this.quizQuestions,
    this.gameContent,
  });

  @override
  List<Object?> get props => [activityId, type];
}

enum ActivityContentType {
  video,
  quiz,
  practice,
  game,
}
