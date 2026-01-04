import '../../domain/entities/activity_entities.dart';

class SignContentModel extends SignContent {
  const SignContentModel({
    required super.id,
    required super.activityId,
    required super.word,
    super.videoUrl,
    super.imageUrl,
    super.audioUrl,
    super.description,
  });

  factory SignContentModel.fromJson(Map<String, dynamic> json) {
    return SignContentModel(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      word: json['word'] as String,
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      description: json['description'] as String?,
    );
  }
}

class QuizOptionModel extends QuizOption {
  const QuizOptionModel({
    required super.id,
    required super.text,
    super.imageUrl,
    required super.isCorrect,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.activityId,
    required super.question,
    super.questionImageUrl,
    super.questionVideoUrl,
    required super.options,
    required super.orderIndex,
    required super.points,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];
    final options = optionsJson
        .map((o) => QuizOptionModel.fromJson(o as Map<String, dynamic>))
        .toList();

    return QuizQuestionModel(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      question: json['question'] as String,
      questionImageUrl: json['questionImageUrl'] as String?,
      questionVideoUrl: json['questionVideoUrl'] as String?,
      options: options,
      orderIndex: json['orderIndex'] as int? ?? 0,
      points: json['points'] as int? ?? 10,
    );
  }
}

class GamePairModel extends GamePair {
  const GamePairModel({
    required super.id,
    required super.word,
    super.imageUrl,
    super.videoUrl,
  });

  factory GamePairModel.fromJson(Map<String, dynamic> json) {
    return GamePairModel(
      id: json['id'] as String,
      word: json['word'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }
}

class GameContentModel extends GameContent {
  const GameContentModel({
    required super.id,
    required super.activityId,
    required super.gameType,
    required super.pairs,
    required super.timeLimit,
    required super.points,
  });

  factory GameContentModel.fromJson(Map<String, dynamic> json) {
    final pairsJson = json['pairs'] as List<dynamic>? ?? [];
    final pairs = pairsJson
        .map((p) => GamePairModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return GameContentModel(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      gameType: GameType.fromString(json['gameType'] as String? ?? 'MATCHING'),
      pairs: pairs,
      timeLimit: json['timeLimit'] as int? ?? 60,
      points: json['points'] as int? ?? 50,
    );
  }
}

class ActivityDataModel extends ActivityData {
  const ActivityDataModel({
    required super.activityId,
    required super.type,
    super.signContents,
    super.quizQuestions,
    super.gameContent,
  });

  factory ActivityDataModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'VIDEO';
    ActivityContentType type;
    
    switch (typeStr.toUpperCase()) {
      case 'VIDEO':
        type = ActivityContentType.video;
        break;
      case 'QUIZ':
        type = ActivityContentType.quiz;
        break;
      case 'PRACTICE':
        type = ActivityContentType.practice;
        break;
      case 'GAME':
        type = ActivityContentType.game;
        break;
      default:
        type = ActivityContentType.video;
    }

    List<SignContentModel>? signContents;
    List<QuizQuestionModel>? quizQuestions;
    GameContentModel? gameContent;

    if (json['signContents'] != null) {
      final list = json['signContents'] as List<dynamic>;
      signContents = list
          .map((s) => SignContentModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    if (json['quizQuestions'] != null) {
      final list = json['quizQuestions'] as List<dynamic>;
      quizQuestions = list
          .map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList();
    }

    if (json['gameContent'] != null) {
      gameContent = GameContentModel.fromJson(
          json['gameContent'] as Map<String, dynamic>);
    }

    return ActivityDataModel(
      activityId: json['activityId'] as String,
      type: type,
      signContents: signContents,
      quizQuestions: quizQuestions,
      gameContent: gameContent,
    );
  }
}
