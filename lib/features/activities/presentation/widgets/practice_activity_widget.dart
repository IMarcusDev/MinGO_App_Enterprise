import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/activity_entities.dart';

/// Widget para práctica de reconocimiento de señas
/// Muestra la seña y el usuario debe identificarla
class PracticeActivityWidget extends StatefulWidget {
  final List<SignContent> contents;
  final Function(ActivityResult) onComplete;

  const PracticeActivityWidget({
    super.key,
    required this.contents,
    required this.onComplete,
  });

  @override
  State<PracticeActivityWidget> createState() => _PracticeActivityWidgetState();
}

class _PracticeActivityWidgetState extends State<PracticeActivityWidget> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isCorrect = false;
  String? _selectedAnswer;
  List<String> _options = [];
  
  int _correctAnswers = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _generateOptions();
  }

  SignContent get currentContent => widget.contents[_currentIndex];
  bool get isLastContent => _currentIndex >= widget.contents.length - 1;

  void _generateOptions() {
    // La respuesta correcta
    final correctAnswer = currentContent.word;
    
    // Obtener otras palabras como opciones incorrectas
    final otherWords = widget.contents
        .where((c) => c.word != correctAnswer)
        .map((c) => c.word)
        .toList();
    
    otherWords.shuffle();
    
    // Tomar 3 opciones incorrectas (o menos si no hay suficientes)
    final incorrectOptions = otherWords.take(3).toList();
    
    // Combinar y mezclar
    _options = [correctAnswer, ...incorrectOptions]..shuffle();
    
    // Si no hay suficientes opciones, agregar algunas genéricas
    while (_options.length < 4) {
      _options.add('Opción ${_options.length + 1}');
    }
  }

  void _selectAnswer(String answer) {
    if (_showAnswer) return;

    setState(() {
      _selectedAnswer = answer;
      _showAnswer = true;
      _isCorrect = answer == currentContent.word;
      
      if (_isCorrect) {
        _correctAnswers++;
      }
    });
  }

  void _nextContent() {
    if (isLastContent) {
      _stopwatch.stop();
      widget.onComplete(ActivityResult(
        activityId: currentContent.activityId,
        score: _correctAnswers * 15,
        maxScore: widget.contents.length * 15,
        correctAnswers: _correctAnswers,
        totalQuestions: widget.contents.length,
        timeTaken: _stopwatch.elapsed,
        passed: _correctAnswers >= widget.contents.length * 0.7,
      ));
    } else {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _selectedAnswer = null;
        _isCorrect = false;
        _generateOptions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress
        LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.contents.length,
          backgroundColor: AppColors.border,
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Práctica ${_currentIndex + 1}/${widget.contents.length}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '$_correctAnswers correctas',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: Column(
              children: [
                // Instruction
                Text(
                  '¿Qué seña es esta?',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spaceL),

                // Sign display
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (currentContent.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          child: Image.network(
                            currentContent.imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        )
                      else
                        _buildPlaceholder(),

                      // Play hint
                      if (!_showAnswer)
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Observa la seña',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceXL),

                // Options
                ...List.generate(_options.length, (index) {
                  final option = _options[index];
                  final isSelected = _selectedAnswer == option;
                  final isCorrectAnswer = option == currentContent.word;

                  Color backgroundColor;
                  Color borderColor;
                  Color textColor;

                  if (_showAnswer) {
                    if (isCorrectAnswer) {
                      backgroundColor = AppColors.success.withOpacity(0.1);
                      borderColor = AppColors.success;
                      textColor = AppColors.success;
                    } else if (isSelected) {
                      backgroundColor = AppColors.error.withOpacity(0.1);
                      borderColor = AppColors.error;
                      textColor = AppColors.error;
                    } else {
                      backgroundColor = AppColors.surface;
                      borderColor = AppColors.border;
                      textColor = AppColors.textSecondary;
                    }
                  } else {
                    backgroundColor = AppColors.surface;
                    borderColor = AppColors.border;
                    textColor = AppColors.textPrimary;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                    child: Material(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                      child: InkWell(
                        onTap: _showAnswer ? null : () => _selectAnswer(option),
                        borderRadius: BorderRadius.circular(AppDimensions.radius),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.space),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimensions.radius),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: borderColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: AppTypography.labelLarge.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space),
                              Expanded(
                                child: Text(
                                  option,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: textColor,
                                    fontWeight: isSelected || (_showAnswer && isCorrectAnswer)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (_showAnswer && isCorrectAnswer)
                                const Icon(Icons.check_circle, color: AppColors.success),
                              if (_showAnswer && isSelected && !isCorrectAnswer)
                                const Icon(Icons.cancel, color: AppColors.error),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Feedback and next
        if (_showAnswer)
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
                      _isCorrect ? Icons.check_circle : Icons.info,
                      color: _isCorrect ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect
                          ? '¡Excelente! 🎉'
                          : 'La respuesta correcta es: ${currentContent.word}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: _isCorrect ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (currentContent.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    currentContent.description!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppDimensions.space),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextContent,
                    child: Text(isLastContent ? 'Ver resultados' : 'Siguiente'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.sign_language,
          size: 80,
          color: Colors.white38,
        ),
        const SizedBox(height: 8),
        Text(
          'Seña de práctica',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}
