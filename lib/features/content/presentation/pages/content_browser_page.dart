import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entities.dart';
import '../bloc/content_bloc.dart';

/// Página de navegación de contenido para docentes
///
/// Esta página permite a los docentes explorar los niveles y módulos
/// sin perder el contexto de navegación (navbar del docente).
class ContentBrowserPage extends StatelessWidget {
  const ContentBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContentBloc>()..add(const LoadLevelSectionsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explorar Contenido'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => AppNavigator.pushNamed(AppRoutes.search),
              tooltip: 'Buscar',
            ),
          ],
        ),
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state is ContentLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ContentErrorState) {
              return _buildError(context, state.message);
            }

            if (state is LevelSectionsLoadedState) {
              return _buildContent(context, state.levels);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<LevelSection> levels) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ContentBloc>().add(const LoadLevelSectionsEvent());
      },
      child: CustomScrollView(
        slivers: [
          // Header informativo
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.space),
              padding: const EdgeInsets.all(AppDimensions.space),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.info.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radius),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_outline, color: AppColors.info),
                  ),
                  const SizedBox(width: AppDimensions.space),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vista de Contenido',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explora los niveles y módulos disponibles para asignar a tus clases.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Título de niveles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space,
                vertical: AppDimensions.spaceS,
              ),
              child: Row(
                children: [
                  Text('Niveles Disponibles', style: AppTypography.titleLarge),
                  const Spacer(),
                  Text(
                    '${levels.length} niveles',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de niveles
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.space),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = levels[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space),
                    child: _LevelCard(
                      level: level,
                      onTap: () => AppNavigator.pushNamed(
                        AppRoutes.levelDetail,
                        arguments: {'levelId': level.id, 'levelName': level.name},
                      ),
                    ),
                  );
                },
                childCount: levels.length,
              ),
            ),
          ),

          // Espacio al final
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceXL),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.space),
            Text(
              'Error al cargar contenido',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            ElevatedButton.icon(
              onPressed: () => context.read<ContentBloc>().add(const LoadLevelSectionsEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelSection level;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.onTap,
  });

  Color get _color => AppColors.getLevelColor(level.level.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        side: BorderSide(color: _color.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            children: [
              // Icono del nivel
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  _getLevelIcon(level.level),
                  color: _color,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppDimensions.space),

              // Información del nivel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            level.name,
                            style: AppTypography.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Nivel ${level.level.value}',
                            style: AppTypography.labelSmall.copyWith(
                              color: _color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (level.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        level.description!,
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
                        Icon(
                          level.isUnlocked ? Icons.lock_open : Icons.lock,
                          size: 16,
                          color: level.isUnlocked ? AppColors.success : AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          level.isUnlocked ? 'Disponible' : 'Bloqueado',
                          style: AppTypography.labelSmall.copyWith(
                            color: level.isUnlocked ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.folder_outlined,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ver módulos',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Flecha
              Icon(
                Icons.chevron_right,
                color: _color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLevelIcon(LevelType level) {
    switch (level) {
      case LevelType.principiante:
        return Icons.emoji_people;
      case LevelType.intermedio:
        return Icons.school;
      case LevelType.avanzado:
        return Icons.workspace_premium;
    }
  }
}
