import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/progress_entities.dart';
import '../bloc/progress_bloc.dart';
import '../widgets/stats_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/activity_chart.dart';
import '../widgets/recent_lessons_list.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgressBloc>()..add(const LoadAllProgressDataEvent()),
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProgressBloc>().add(const LoadAllProgressDataEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProgressErrorState) {
            return _buildError(context, state.message);
          }

          if (state is ProgressLoadedState) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppDimensions.space),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.space),
          ElevatedButton(
            onPressed: () {
              context.read<ProgressBloc>().add(const LoadAllProgressDataEvent());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProgressLoadedState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProgressBloc>().add(const LoadAllProgressDataEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Racha de días
            if (state.streak != null) ...[
              StreakCard(streak: state.streak!),
              const SizedBox(height: AppDimensions.spaceL),
            ],

            // Estadísticas principales
            if (state.stats != null) ...[
              Text('Estadísticas', style: AppTypography.titleLarge),
              const SizedBox(height: AppDimensions.space),
              _buildStatsGrid(state.stats!),
              const SizedBox(height: AppDimensions.spaceL),
            ],

            // Gráfico de actividad
            if (state.dailyActivity.isNotEmpty) ...[
              Text('Actividad semanal', style: AppTypography.titleLarge),
              const SizedBox(height: AppDimensions.space),
              ActivityChart(dailyActivity: state.dailyActivity),
              const SizedBox(height: AppDimensions.spaceL),
            ],

            // Lecciones recientes
            if (state.progress.isNotEmpty) ...[
              Text('Lecciones recientes', style: AppTypography.titleLarge),
              const SizedBox(height: AppDimensions.space),
              RecentLessonsList(lessons: state.progress.take(5).toList()),
            ],

            // Estado vacío
            if (state.stats == null && state.progress.isEmpty)
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(UserStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppDimensions.space,
      crossAxisSpacing: AppDimensions.space,
      childAspectRatio: 1.5,
      children: [
        StatsCard(
          icon: Icons.school,
          title: 'Lecciones',
          value: '${stats.totalLessonsCompleted}',
          subtitle: 'completadas',
          color: AppColors.primary,
        ),
        StatsCard(
          icon: Icons.percent,
          title: 'Precisión',
          value: '${stats.averageAccuracy.toInt()}%',
          subtitle: 'promedio',
          color: _getAccuracyColor(stats.averageAccuracy),
        ),
        StatsCard(
          icon: Icons.timer,
          title: 'Tiempo',
          value: stats.totalTimeFormatted,
          subtitle: 'de estudio',
          color: AppColors.secondary,
        ),
        StatsCard(
          icon: Icons.lock_open,
          title: 'Niveles',
          value: '${stats.unlockedLevels}',
          subtitle: 'desbloqueados',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 100,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.space),
            Text(
              '¡Comienza a aprender!',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'Completa lecciones para ver tu progreso aquí',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
