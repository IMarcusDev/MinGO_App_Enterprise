import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/progress_entities.dart';

class ActivityChart extends StatelessWidget {
  final List<DailyActivity> dailyActivity;

  const ActivityChart({super.key, required this.dailyActivity});

  @override
  Widget build(BuildContext context) {
    // Encontrar máximo para escala
    final maxLessons = dailyActivity.fold<int>(
      1,
      (max, activity) => activity.lessonsCompleted > max ? activity.lessonsCompleted : max,
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Gráfico de barras
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyActivity.map((activity) {
                final height = maxLessons > 0
                    ? (activity.lessonsCompleted / maxLessons) * 120
                    : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Valor
                        if (activity.lessonsCompleted > 0)
                          Text(
                            '${activity.lessonsCompleted}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        
                        // Barra
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: height > 0 ? height : 4,
                          decoration: BoxDecoration(
                            color: activity.lessonsCompleted > 0
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Día
                        Text(
                          _getDayLabel(activity.date),
                          style: AppTypography.labelSmall.copyWith(
                            color: _isToday(activity.date)
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: _isToday(activity.date)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: AppDimensions.space),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceS),
          
          // Resumen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Total lecciones',
                value: '${_totalLessons}',
                icon: Icons.school,
              ),
              _SummaryItem(
                label: 'Tiempo total',
                value: _formatTime(_totalTime),
                icon: Icons.timer,
              ),
              _SummaryItem(
                label: 'Precisión prom.',
                value: '${_averageAccuracy.toInt()}%',
                icon: Icons.percent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    if (_isToday(date)) return 'Hoy';
    
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int get _totalLessons => dailyActivity.fold(
        0,
        (sum, activity) => sum + activity.lessonsCompleted,
      );

  int get _totalTime => dailyActivity.fold(
        0,
        (sum, activity) => sum + activity.timeSpent,
      );

  double get _averageAccuracy {
    final withActivity = dailyActivity.where((a) => a.lessonsCompleted > 0);
    if (withActivity.isEmpty) return 0;
    return withActivity.fold(0.0, (sum, a) => sum + a.accuracy) / withActivity.length;
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
