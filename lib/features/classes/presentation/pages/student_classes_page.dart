import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/class_entities.dart';
import '../bloc/class_bloc.dart';

class StudentClassesPage extends StatelessWidget {
  const StudentClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassBloc>()..add(const LoadEnrolledClassesEvent()),
      child: const _StudentClassesView(),
    );
  }
}

class _StudentClassesView extends StatelessWidget {
  const _StudentClassesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showJoinDialog(context),
            tooltip: 'Unirse a clase',
          ),
        ],
      ),
      body: BlocConsumer<ClassBloc, ClassState>(
        listener: (context, state) {
          if (state is JoinedClassState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Te has unido a la clase!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<ClassBloc>().add(const LoadEnrolledClassesEvent());
          } else if (state is LeftClassState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Has salido de la clase'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<ClassBloc>().add(const LoadEnrolledClassesEvent());
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

          if (state is EnrolledClassesLoadedState) {
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
        onPressed: () => _showJoinDialog(context),
        icon: const Icon(Icons.qr_code),
        label: const Text('Unirse'),
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
              'No estás inscrito en ninguna clase',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'Pide el código a tu profesor y únete',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            ElevatedButton.icon(
              onPressed: () => _showJoinDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Unirse con código'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList(BuildContext context, List<SchoolClass> classes) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassBloc>().add(const LoadEnrolledClassesEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.space),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return _EnrolledClassCard(
            schoolClass: classes[index],
            onTap: () => AppNavigator.pushNamed(
              AppRoutes.classDetail,
              arguments: classes[index].id,
            ),
            onLeave: () => _confirmLeave(context, classes[index]),
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
              context.read<ClassBloc>().add(const LoadEnrolledClassesEvent());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unirse a Clase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el código de 6 caracteres que te dio tu profesor',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.space),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código de clase',
                hintText: 'Ej: ABC123',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 20,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
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
              final code = codeController.text.trim().toUpperCase();
              if (code.length == 6) {
                context.read<ClassBloc>().add(
                      JoinClassEvent(JoinClassParams(code: code)),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salir de Clase'),
        content: Text(
          '¿Estás seguro de salir de "${schoolClass.name}"?\n\n'
          'Podrás volver a unirte con el código.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ClassBloc>().add(LeaveClassEvent(schoolClass.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

class _EnrolledClassCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final VoidCallback onTap;
  final VoidCallback onLeave;

  const _EnrolledClassCard({
    required this.schoolClass,
    required this.onTap,
    required this.onLeave,
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Icon(
                  Icons.school,
                  color: AppColors.secondary,
                  size: 30,
                ),
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
                    if (schoolClass.teacherName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schoolClass.teacherName!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${schoolClass.studentsCount} compañeros',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'leave') onLeave();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Salir'),
                      ],
                    ),
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
