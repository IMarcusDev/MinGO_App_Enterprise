import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entities.dart';
import '../bloc/content_bloc.dart';

class ModuleDetailPage extends StatelessWidget {
  final String moduleId;
  final String moduleName;

  const ModuleDetailPage({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContentBloc>()..add(LoadLessonsEvent(moduleId)),
      child: _ModuleDetailView(moduleName: moduleName),
    );
  }
}

class _ModuleDetailView extends StatelessWidget {
  final String moduleName;

  const _ModuleDetailView({required this.moduleName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(moduleName),
      ),
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (state is ContentLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ContentErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppDimensions.space),
                  Text(state.message),
                  const SizedBox(height: AppDimensions.space),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is LessonsLoadedState) {
            if (state.lessons.isEmpty) {
              return _buildEmptyState();
            }
            return _buildLessonsList(context, state.lessons);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 80, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: AppDimensions.space),
          Text('No hay lecciones disponibles', style: AppTypography.titleMedium),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'Próximamente',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList(BuildContext context, List<Lesson> lessons) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.space),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _LessonCard(
          lesson: lesson,
          index: index + 1,
          onTap: () => AppNavigator.pushNamed(
            AppRoutes.activity,
            arguments: lesson.id,
          ),
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            children: [
              // Número de lección
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.success 
                      : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : Text(
                          '$index',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppDimensions.space),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AppTypography.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lesson.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (lesson.duration != null) ...[
                          Icon(Icons.timer_outlined, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.duration} min',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.extension, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.activitiesCount} actividades',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress indicator
              if (lesson.userProgress != null && !isCompleted) ...[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: lesson.userProgress!.accuracy / 100,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                      Center(
                        child: Text(
                          '${lesson.userProgress!.accuracy.toInt()}%',
                          style: AppTypography.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
