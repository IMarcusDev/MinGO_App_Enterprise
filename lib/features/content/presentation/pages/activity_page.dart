import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entities.dart';
import '../bloc/content_bloc.dart';

class ActivityPage extends StatelessWidget {
  final String activityId;

  const ActivityPage({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContentBloc>()..add(LoadActivitiesEvent(activityId)),
      child: const _ActivityView(),
    );
  }
}

class _ActivityView extends StatefulWidget {
  const _ActivityView();

  @override
  State<_ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<_ActivityView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades'),
      ),
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (state is ContentLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ContentErrorState) {
            return Center(child: Text(state.message));
          }
          if (state is ActivitiesLoadedState) {
            if (state.activities.isEmpty) {
              return const Center(child: Text('No hay actividades'));
            }
            return _buildContent(state.activities);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(List<Activity> activities) {
    final activity = activities[_currentIndex];
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / activities.length,
          backgroundColor: AppColors.border,
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Text('${_currentIndex + 1} / ${activities.length}',
              style: AppTypography.labelMedium),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getIcon(activity.activityType), size: 80, color: AppColors.primary),
                const SizedBox(height: AppDimensions.space),
                Text(activity.title, style: AppTypography.titleLarge),
                if (activity.description != null) ...[
                  const SizedBox(height: 8),
                  Text(activity.description!, style: AppTypography.bodyMedium),
                ],
                const SizedBox(height: AppDimensions.spaceL),
                Text('+${activity.points} puntos',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.warning)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentIndex--),
                    child: const Text('Anterior'),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < activities.length - 1) {
                      setState(() => _currentIndex++);
                    } else {
                      _complete();
                    }
                  },
                  child: Text(_currentIndex < activities.length - 1 ? 'Siguiente' : 'Completar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.video:
        return Icons.play_circle;
      case ActivityType.quiz:
        return Icons.quiz;
      case ActivityType.practice:
        return Icons.front_hand;
      case ActivityType.game:
        return Icons.sports_esports;
    }
  }

  void _complete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Felicitaciones! 🎉'),
        content: const Text('Completaste esta lección'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
