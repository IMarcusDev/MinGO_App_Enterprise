import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/activity_entities.dart';

/// Widget para mostrar resultados de una actividad completada
class ActivityResultWidget extends StatelessWidget {
  final ActivityResult result;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const ActivityResultWidget({
    super.key,
    required this.result,
    required this.onContinue,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = result.passed;
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji/Icon
              Text(
                isPassed ? '🎉' : '💪',
                style: const TextStyle(fontSize: 80),
              ),
              
              const SizedBox(height: AppDimensions.spaceL),
              
              // Title
              Text(
                isPassed ? '¡Felicitaciones!' : '¡Sigue practicando!',
                style: AppTypography.headlineMedium.copyWith(
                  color: isPassed ? AppColors.success : AppColors.warning,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceS),
              
              Text(
                isPassed
                    ? 'Has completado esta actividad exitosamente'
                    : 'Necesitas más práctica para dominar esta actividad',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),
              
              // Stats card
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Column(
                  children: [
                    // Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: AppColors.warning, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          '${result.score}',
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${result.maxScore} pts',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceL),
                    const Divider(),
                    const SizedBox(height: AppDimensions.spaceL),
                    
                    // Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn(
                          icon: Icons.check_circle,
                          value: '${result.correctAnswers}/${result.totalQuestions}',
                          label: 'Correctas',
                          color: AppColors.success,
                        ),
                        _StatColumn(
                          icon: Icons.percent,
                          value: '${result.accuracy.toInt()}%',
                          label: 'Precisión',
                          color: AppColors.primary,
                        ),
                        _StatColumn(
                          icon: Icons.timer,
                          value: _formatDuration(result.timeTaken),
                          label: 'Tiempo',
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),
              
              // Progress indicator
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progreso', style: AppTypography.labelMedium),
                      Text(
                        '${result.accuracy.toInt()}%',
                        style: AppTypography.labelMedium.copyWith(
                          color: _getProgressColor(result.accuracy),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: result.accuracy / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(result.accuracy),
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Buttons
              if (onRetry != null && !isPassed) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay),
                    label: const Text('Intentar de nuevo'),
                  ),
                ),
                const SizedBox(height: AppDimensions.space),
              ],
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
