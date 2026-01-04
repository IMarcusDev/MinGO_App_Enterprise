import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/child_entity.dart';
import '../bloc/children_bloc.dart';

class ChildrenListPage extends StatelessWidget {
  const ChildrenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChildrenBloc>()..add(const LoadChildrenEvent()),
      child: const _ChildrenListView(),
    );
  }
}

class _ChildrenListView extends StatelessWidget {
  const _ChildrenListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Hijos'),
      ),
      body: BlocConsumer<ChildrenBloc, ChildrenState>(
        listener: (context, state) {
          if (state is ChildDeletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil eliminado'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<ChildrenBloc>().add(const LoadChildrenEvent());
          } else if (state is ChildrenErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChildrenLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChildrenLoadedState) {
            if (state.children.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildList(context, state.children);
          }

          if (state is ChildrenErrorState) {
            return _buildErrorState(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await AppNavigator.pushNamed(AppRoutes.childForm);
          if (result == true && context.mounted) {
            context.read<ChildrenBloc>().add(const LoadChildrenEvent());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 100,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'No tienes hijos registrados',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'Agrega la información de tus hijos para personalizar el contenido educativo',
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

  Widget _buildList(BuildContext context, List<Child> children) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.space),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return _ChildCard(
          child: child,
          onTap: () async {
            final result = await AppNavigator.pushNamed(
              AppRoutes.childForm,
              arguments: child.id,
            );
            if (result == true && context.mounted) {
              context.read<ChildrenBloc>().add(const LoadChildrenEvent());
            }
          },
          onDelete: () => _showDeleteDialog(context, child),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppDimensions.space),
          Text(message, style: AppTypography.bodyMedium),
          const SizedBox(height: AppDimensions.space),
          ElevatedButton(
            onPressed: () {
              context.read<ChildrenBloc>().add(const LoadChildrenEvent());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Child child) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text('¿Estás seguro de eliminar el perfil de ${child.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChildrenBloc>().add(DeleteChildEvent(child.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onDelete,
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
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: child.avatarUrl != null
                    ? NetworkImage(child.avatarUrl!)
                    : null,
                child: child.avatarUrl == null
                    ? Text(
                        child.name[0].toUpperCase(),
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.space),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: AppTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${child.age} años • ${child.ageCategory}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (child.disabilityType != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          child.disabilityType!.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onTap();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
