import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/activity_entities.dart';

/// Widget para quiz de opción múltiple
class QuizActivityWidget extends StatefulWidget {
  final List<QuizQuestion> questions;
  final Function(ActivityResult) onComplete;

  const QuizActivityWidget({
    super.key,
    required this.questions,
    required this.onComplete,
  });

  @override
  State<QuizActivityWidget> createState() => _QuizActivityWidgetState();
}

class _QuizActivityWidgetState extends State<QuizActivityWidget> {
  int _currentIndex = 0;
  String? _selectedOptionId;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  
  int _correctAnswers = 0;
  int _totalScore = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  QuizQuestion get currentQuestion => widget.questions[_currentIndex];
  bool get isLastQuestion => _currentIndex >= widget.questions.length - 1;

  void _selectOption(QuizOption option) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOptionId = option.id;
      _hasAnswered = true;
      _isCorrect = option.isCorrect;

      if (_isCorrect) {
        _correctAnswers++;
        _totalScore += currentQuestion.points;
      }
    });
  }

  void _nextQuestion() {
    if (isLastQuestion) {
      _stopwatch.stop();
      final maxScore = widget.questions.fold<int>(
        0,
        (sum, q) => sum + q.points,
      );

      widget.onComplete(ActivityResult(
        activityId: currentQuestion.activityId,
        score: _totalScore,
        maxScore: maxScore,
        correctAnswers: _correctAnswers,
        totalQuestions: widget.questions.length,
        timeTaken: _stopwatch.elapsed,
        passed: _correctAnswers >= widget.questions.length * 0.7,
      ));
    } else {
      setState(() {
        _currentIndex++;
        _selectedOptionId = null;
        _hasAnswered = false;
        _isCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.questions.length,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta ${_currentIndex + 1}/${widget.questions.length}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
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
                      '$_totalScore pts',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
            child: Column(
              children: [
                // Question image/video
                if (currentQuestion.questionImageUrl != null ||
                    currentQuestion.questionVideoUrl != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppDimensions.space),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: currentQuestion.questionImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                            child: Image.network(
                              currentQuestion.questionImageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppColors.textHint,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                  ),

                // Question text
                Text(
                  currentQuestion.question,
                  style: AppTypography.titleLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spaceL),

                // Options
                ...currentQuestion.options.map((option) {
                  final isSelected = _selectedOptionId == option.id;
                  final showResult = _hasAnswered;

                  Color backgroundColor;
                  Color borderColor;
                  Color textColor;

                  if (showResult) {
                    if (option.isCorrect) {
                      backgroundColor = AppColors.success.withOpacity(0.1);
                      borderColor = AppColors.success;
                      textColor = AppColors.success;
                    } else if (isSelected && !option.isCorrect) {
                      backgroundColor = AppColors.error.withOpacity(0.1);
                      borderColor = AppColors.error;
                      textColor = AppColors.error;
                    } else {
                      backgroundColor = AppColors.surface;
                      borderColor = AppColors.border;
                      textColor = AppColors.textSecondary;
                    }
                  } else {
                    backgroundColor = isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surface;
                    borderColor = isSelected ? AppColors.primary : AppColors.border;
                    textColor = AppColors.textPrimary;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                    child: InkWell(
                      onTap: _hasAnswered ? null : () => _selectOption(option),
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.space),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(AppDimensions.radius),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            if (option.imageUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  option.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: AppColors.border,
                                    child: const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space),
                            ],
                            Expanded(
                              child: Text(
                                option.text,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (showResult)
                              Icon(
                                option.isCorrect
                                    ? Icons.check_circle
                                    : (isSelected ? Icons.cancel : null),
                                color: option.isCorrect
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Feedback and next button
        if (_hasAnswered)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.space),
            color: _isCorrect
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect ? '¡Correcto! 🎉' : 'Incorrecto 😕',
                      style: AppTypography.titleMedium.copyWith(
                        color: _isCorrect ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                if (_isCorrect) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${currentQuestion.points} puntos',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.space),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(isLastQuestion ? 'Ver resultados' : 'Siguiente'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
