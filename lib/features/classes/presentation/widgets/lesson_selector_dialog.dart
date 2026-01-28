import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../../content/domain/entities/content_entities.dart';
import '../../../content/presentation/bloc/content_bloc.dart';

/// Resultado de selección de lección
class LessonSelection {
  final String lessonId;
  final String lessonTitle;
  final String moduleName;

  const LessonSelection({
    required this.lessonId,
    required this.lessonTitle,
    required this.moduleName,
  });
}

/// Dialog para seleccionar una lección para asignar a la clase
class LessonSelectorDialog extends StatefulWidget {
  const LessonSelectorDialog({super.key});

  /// Muestra el dialog y devuelve la lección seleccionada
  static Future<LessonSelection?> show(BuildContext context) {
    return showModalBottomSheet<LessonSelection>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) => const LessonSelectorDialog(),
    );
  }

  @override
  State<LessonSelectorDialog> createState() => _LessonSelectorDialogState();
}

class _LessonSelectorDialogState extends State<LessonSelectorDialog> {
  String? _selectedModuleId;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContentBloc>()..add(const LoadModulesEvent()),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
              child: Row(
                children: [
                  const Icon(Icons.school, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.spaceS),
                  Text('Seleccionar Lección', style: AppTypography.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar lecciones...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space,
                    vertical: AppDimensions.spaceS,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<ContentBloc, ContentState>(
                builder: (context, state) {
                  if (state is ContentLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ContentErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: AppDimensions.space),
                          Text(state.message),
                          const SizedBox(height: AppDimensions.space),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ContentBloc>().add(const LoadModulesEvent());
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ModulesLoadedState) {
                    return _buildModulesContent(context, state.modules, scrollController);
                  }

                  if (state is LessonsLoadedState) {
                    return _buildLessonsContent(context, state.lessons, scrollController);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesContent(
    BuildContext context,
    List<Module> modules,
    ScrollController scrollController,
  ) {
    // Filtrar módulos si hay búsqueda
    final filteredModules = _searchQuery.isEmpty
        ? modules
        : modules.where((m) {
            return m.title.toLowerCase().contains(_searchQuery) ||
                (m.description?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();

    if (filteredModules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.textHint),
            const SizedBox(height: AppDimensions.space),
            const Text('No se encontraron módulos'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppDimensions.space),
      itemCount: filteredModules.length,
      itemBuilder: (context, index) {
        final module = filteredModules[index];
        return _ModuleCard(
          module: module,
          onTap: () {
            setState(() => _selectedModuleId = module.id);
            context.read<ContentBloc>().add(LoadLessonsEvent(module.id));
          },
        );
      },
    );
  }

  Widget _buildLessonsContent(
    BuildContext context,
    List<Lesson> lessons,
    ScrollController scrollController,
  ) {
    // Filtrar lecciones si hay búsqueda
    final filteredLessons = _searchQuery.isEmpty
        ? lessons
        : lessons.where((l) {
            return l.title.toLowerCase().contains(_searchQuery) ||
                (l.description?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();

    return Column(
      children: [
        // Back button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() => _selectedModuleId = null);
                  context.read<ContentBloc>().add(const LoadModulesEvent());
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver a módulos'),
              ),
            ],
          ),
        ),

        // Lessons list
        Expanded(
          child: filteredLessons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: AppColors.textHint),
                      const SizedBox(height: AppDimensions.space),
                      const Text('No se encontraron lecciones'),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.space),
                  itemCount: filteredLessons.length,
                  itemBuilder: (context, index) {
                    final lesson = filteredLessons[index];
                    return _LessonCard(
                      lesson: lesson,
                      onTap: () {
                        Navigator.pop(
                          context,
                          LessonSelection(
                            lessonId: lesson.id,
                            lessonTitle: lesson.title,
                            moduleName: lesson.moduleId,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Module module;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          child: module.thumbnailUrl != null
              ? Image.network(
                  module.thumbnailUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        title: Text(module.title, style: AppTypography.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (module.description != null)
              Text(
                module.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${module.lessonsCount} lecciones',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: const Icon(Icons.folder, color: AppColors.primary),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: const Icon(Icons.school, color: AppColors.primary),
        ),
        title: Text(lesson.title, style: AppTypography.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lesson.description != null)
              Text(
                lesson.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (lesson.duration != null) ...[
                  Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '${lesson.duration} min',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                ],
                Icon(Icons.play_circle_outline, size: 14, color: AppColors.textHint),
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
        trailing: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceS),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppColors.success, size: 20),
        ),
        onTap: onTap,
      ),
    );
  }
}
