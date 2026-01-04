import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../content/domain/entities/content_entities.dart' hide SignContent;
import '../../domain/entities/activity_entities.dart';
import '../widgets/video_activity_widget.dart';
import '../widgets/quiz_activity_widget.dart';
import '../widgets/practice_activity_widget.dart';
import '../widgets/game_activity_widget.dart';
import '../widgets/activity_result_widget.dart';

/// Página de actividad interactiva que muestra el tipo correcto de actividad
class InteractiveActivityPage extends StatefulWidget {
  final Activity activity;
  final ActivityData? activityData;

  const InteractiveActivityPage({
    super.key,
    required this.activity,
    this.activityData,
  });

  @override
  State<InteractiveActivityPage> createState() => _InteractiveActivityPageState();
}

class _InteractiveActivityPageState extends State<InteractiveActivityPage> {
  ActivityResult? _result;
  bool _showResult = false;

  void _onActivityComplete(ActivityResult result) {
    setState(() {
      _result = result;
      _showResult = true;
    });

    // TODO: Guardar progreso en el servidor
  }

  void _onContinue() {
    Navigator.pop(context, _result);
  }

  void _onRetry() {
    setState(() {
      _result = null;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si hay resultado, mostrar pantalla de resultados
    if (_showResult && _result != null) {
      return Scaffold(
        body: ActivityResultWidget(
          result: _result!,
          onContinue: _onContinue,
          onRetry: _result!.passed ? null : _onRetry,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  '+${widget.activity.points} pts',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildActivityContent(),
    );
  }

  Widget _buildActivityContent() {
    // Si tenemos datos de actividad cargados
    if (widget.activityData != null) {
      return _buildWithData(widget.activityData!);
    }

    // Si no hay datos, mostrar contenido de demostración
    return _buildDemoContent();
  }

  Widget _buildWithData(ActivityData data) {
    switch (data.type) {
      case ActivityContentType.video:
        if (data.signContents != null && data.signContents!.isNotEmpty) {
          return VideoActivityWidget(
            contents: data.signContents!,
            onComplete: () => _onActivityComplete(ActivityResult(
              activityId: widget.activity.id,
              score: widget.activity.points,
              maxScore: widget.activity.points,
              correctAnswers: data.signContents!.length,
              totalQuestions: data.signContents!.length,
              timeTaken: const Duration(minutes: 2),
              passed: true,
            )),
          );
        }
        break;

      case ActivityContentType.quiz:
        if (data.quizQuestions != null && data.quizQuestions!.isNotEmpty) {
          return QuizActivityWidget(
            questions: data.quizQuestions!,
            onComplete: _onActivityComplete,
          );
        }
        break;

      case ActivityContentType.practice:
        if (data.signContents != null && data.signContents!.isNotEmpty) {
          return PracticeActivityWidget(
            contents: data.signContents!,
            onComplete: _onActivityComplete,
          );
        }
        break;

      case ActivityContentType.game:
        if (data.gameContent != null) {
          return GameActivityWidget(
            gameContent: data.gameContent!,
            onComplete: _onActivityComplete,
          );
        }
        break;
    }

    return _buildDemoContent();
  }

  Widget _buildDemoContent() {
    // Contenido de demostración basado en el tipo de actividad
    switch (widget.activity.activityType) {
      case ActivityType.video:
        return VideoActivityWidget(
          contents: _getDemoSignContents(),
          onComplete: () => _onActivityComplete(_getDemoResult()),
        );

      case ActivityType.quiz:
        return QuizActivityWidget(
          questions: _getDemoQuizQuestions(),
          onComplete: _onActivityComplete,
        );

      case ActivityType.practice:
        return PracticeActivityWidget(
          contents: _getDemoSignContents(),
          onComplete: _onActivityComplete,
        );

      case ActivityType.game:
        return GameActivityWidget(
          gameContent: _getDemoGameContent(),
          onComplete: _onActivityComplete,
        );
    }
  }

  // Datos de demostración
  List<SignContent> _getDemoSignContents() {
    return [
      const SignContent(
        id: 'demo1',
        activityId: 'demo',
        word: 'Hola',
        description: 'Saludo básico en lengua de señas',
      ),
      const SignContent(
        id: 'demo2',
        activityId: 'demo',
        word: 'Gracias',
        description: 'Expresión de agradecimiento',
      ),
      const SignContent(
        id: 'demo3',
        activityId: 'demo',
        word: 'Por favor',
        description: 'Expresión de cortesía',
      ),
    ];
  }

  List<QuizQuestion> _getDemoQuizQuestions() {
    return const [
      QuizQuestion(
        id: 'q1',
        activityId: 'demo',
        question: '¿Cuál es la seña para "Hola"?',
        options: [
          QuizOption(id: 'o1', text: 'Mano levantada saludando', isCorrect: true),
          QuizOption(id: 'o2', text: 'Mano en el pecho', isCorrect: false),
          QuizOption(id: 'o3', text: 'Dedos cruzados', isCorrect: false),
          QuizOption(id: 'o4', text: 'Puño cerrado', isCorrect: false),
        ],
        orderIndex: 0,
        points: 10,
      ),
      QuizQuestion(
        id: 'q2',
        activityId: 'demo',
        question: '¿Cómo se dice "Gracias" en señas?',
        options: [
          QuizOption(id: 'o1', text: 'Mano en la barbilla hacia adelante', isCorrect: true),
          QuizOption(id: 'o2', text: 'Aplaudir', isCorrect: false),
          QuizOption(id: 'o3', text: 'Señalar arriba', isCorrect: false),
          QuizOption(id: 'o4', text: 'Manos juntas', isCorrect: false),
        ],
        orderIndex: 1,
        points: 10,
      ),
    ];
  }

  GameContent _getDemoGameContent() {
    return const GameContent(
      id: 'game1',
      activityId: 'demo',
      gameType: GameType.memory,
      pairs: [
        GamePair(id: 'p1', word: 'Hola'),
        GamePair(id: 'p2', word: 'Adiós'),
        GamePair(id: 'p3', word: 'Gracias'),
        GamePair(id: 'p4', word: 'Por favor'),
      ],
      timeLimit: 60,
      points: 50,
    );
  }

  ActivityResult _getDemoResult() {
    return ActivityResult(
      activityId: widget.activity.id,
      score: widget.activity.points,
      maxScore: widget.activity.points,
      correctAnswers: 3,
      totalQuestions: 3,
      timeTaken: const Duration(minutes: 1, seconds: 30),
      passed: true,
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la actividad?'),
        content: const Text('Perderás el progreso de esta actividad.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
