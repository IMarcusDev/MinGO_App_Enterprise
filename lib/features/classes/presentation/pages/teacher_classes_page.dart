import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/class_entities.dart';
import '../bloc/class_bloc.dart';

class TeacherClassesPage extends StatelessWidget {
  const TeacherClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassBloc>()..add(const LoadTeacherClassesEvent()),
      child: const _TeacherClassesView(),
    );
  }
}

class _TeacherClassesView extends StatelessWidget {
  const _TeacherClassesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ClassBloc>().add(const LoadTeacherClassesEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<ClassBloc, ClassState>(
        listener: (context, state) {
          if (state is ClassCreatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Clase "${state.schoolClass.name}" creada'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<ClassBloc>().add(const LoadTeacherClassesEvent());
          } else if (state is ClassDeletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clase eliminada'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<ClassBloc>().add(const LoadTeacherClassesEvent());
          } else if (state is ClassErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ClassLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TeacherClassesLoadedState) {
            if (state.classList.classes.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildClassesList(context, state.classList.classes);
          }

          if (state is ClassErrorState) {
            return _buildError(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Clase'),
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
              Icons.school_outlined,
              size: 100,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.space),
            Text(
              'No tienes clases aún',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'Crea tu primera clase para empezar a enseñar',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Crear Clase'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList(BuildContext context, List<SchoolClass> classes) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassBloc>().add(const LoadTeacherClassesEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.space),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return _ClassCard(
            schoolClass: classes[index],
            onTap: () => AppNavigator.pushNamed(
              AppRoutes.classDetail,
              arguments: classes[index].id,
            ),
            onDelete: () => _confirmDelete(context, classes[index]),
          );
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
          Text(message),
          const SizedBox(height: AppDimensions.space),
          ElevatedButton(
            onPressed: () {
              context.read<ClassBloc>().add(const LoadTeacherClassesEvent());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Clase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la clase',
                hintText: 'Ej: Lengua de Señas - Nivel 1',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppDimensions.space),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Descripción breve...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<ClassBloc>().add(CreateClassEvent(
                      CreateClassParams(
                        name: nameController.text.trim(),
                        description: descController.text.trim().isNotEmpty
                            ? descController.text.trim()
                            : null,
                      ),
                    ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Clase'),
        content: Text(
          '¿Estás seguro de eliminar "${schoolClass.name}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ClassBloc>().add(DeleteClassEvent(schoolClass.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.schoolClass,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: const Icon(Icons.class_, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppDimensions.space),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schoolClass.name,
                          style: AppTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${schoolClass.studentsCount} estudiantes',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space),
              
              // Código de clase
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.vpn_key, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Código: ${schoolClass.code}',
                      style: AppTypography.labelLarge.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: schoolClass.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado')),
                        );
                      },
                      child: const Icon(Icons.copy, size: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
