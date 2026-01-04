import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entities.dart';
import '../bloc/content_bloc.dart';

class LevelDetailPage extends StatelessWidget {
  final String levelId;
  final String levelName;

  const LevelDetailPage({
    super.key,
    required this.levelId,
    required this.levelName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContentBloc>()..add(LoadModulesEvent(levelSectionId: levelId)),
      child: _LevelDetailView(levelName: levelName),
    );
  }
}

class _LevelDetailView extends StatelessWidget {
  final String levelName;

  const _LevelDetailView({required this.levelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(levelName),
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
                    onPressed: () {
                      // Reload
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ModulesLoadedState) {
            if (state.modules.isEmpty) {
              return _buildEmptyState();
            }
            return _buildModulesList(context, state.modules);
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
          Icon(Icons.folder_open, size: 80, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: AppDimensions.space),
          Text('No hay módulos disponibles', style: AppTypography.titleMedium),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'Próximamente agregaremos contenido',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList(BuildContext context, List<Module> modules) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.space),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _ModuleCard(
          module: module,
          onTap: () => AppNavigator.pushNamed(
            AppRoutes.moduleDetail,
            arguments: {
              'moduleId': module.id,
              'moduleName': module.title,
            },
          ),
        );
      },
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
      margin: const EdgeInsets.only(bottom: AppDimensions.space),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  image: module.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(module.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: module.thumbnailUrl == null
                    ? const Icon(Icons.menu_book, color: AppColors.primary, size: 32)
                    : null,
              ),
              const SizedBox(width: AppDimensions.space),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (module.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        module.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.play_lesson, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${module.lessonsCount} lecciones',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
