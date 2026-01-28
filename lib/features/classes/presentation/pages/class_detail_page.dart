import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/class_entities.dart';
import '../bloc/class_bloc.dart';
import '../widgets/lesson_selector_dialog.dart';

class ClassDetailPage extends StatelessWidget {
  final String classId;

  const ClassDetailPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassBloc>()..add(LoadClassDetailEvent(classId)),
      child: _ClassDetailView(classId: classId),
    );
  }
}

class _ClassDetailView extends StatefulWidget {
  final String classId;

  const _ClassDetailView({required this.classId});

  @override
  State<_ClassDetailView> createState() => _ClassDetailViewState();
}

class _ClassDetailViewState extends State<_ClassDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClassBloc, ClassState>(
      listener: (context, state) {
        if (state is AssignmentCreatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea creada'),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<ClassBloc>().add(LoadClassDetailEvent(widget.classId));
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
          return Scaffold(
            appBar: AppBar(title: const Text('Cargando...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ClassDetailLoadedState) {
          return _buildContent(context, state);
        }

        if (state is ClassErrorState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.message)),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, ClassDetailLoadedState state) {
    final schoolClass = state.schoolClass;

    return Scaffold(
      appBar: AppBar(
        title: Text(schoolClass.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCode(context, schoolClass.code),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tareas', icon: Icon(Icons.assignment)),
            Tab(text: 'Estudiantes', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header con info de clase
          Container(
            padding: const EdgeInsets.all(AppDimensions.space),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (schoolClass.description != null)
                        Text(
                          schoolClass.description!,
                          style: AppTypography.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.vpn_key, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Código: ${schoolClass.code}',
                            style: AppTypography.labelLarge.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: schoolClass.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Código copiado')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${schoolClass.studentsCount}',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'estudiantes',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AssignmentsTab(
                  assignments: state.assignments,
                  onCreateAssignment: () => _showCreateAssignmentDialog(context),
                ),
                _StudentsTab(
                  classId: widget.classId,
                  students: state.students,
                  onRefresh: () {
                    context.read<ClassBloc>().add(
                          LoadClassStudentsEvent(widget.classId),
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAssignmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _shareCode(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compartir Código'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Comparte este código con tus estudiantes:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: AppTypography.headlineMedium.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado')),
              );
            },
            child: const Text('Copiar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showCreateAssignmentDialog(BuildContext context) async {
    // Primero seleccionar la lección
    final lessonSelection = await LessonSelectorDialog.show(context);

    if (lessonSelection == null || !context.mounted) return;

    // Luego mostrar el dialog para completar los detalles
    final titleController = TextEditingController(
      text: 'Practicar: ${lessonSelection.lessonTitle}',
    );
    final descController = TextEditingController();
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Tarea'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lección seleccionada
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppDimensions.spaceS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lección seleccionada:',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              lessonSelection.lessonTitle,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCreateAssignmentDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space),

                // Título
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título de la tarea',
                    hintText: 'Ej: Practicar saludos básicos',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.space),

                // Descripción
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Instrucciones adicionales...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.space),

                // Fecha de vencimiento
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDueDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de entrega (opcional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedDueDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDueDate!)
                          : 'Sin fecha límite',
                      style: TextStyle(
                        color: selectedDueDate != null
                            ? null
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  context.read<ClassBloc>().add(
                        CreateAssignmentEvent(
                          widget.classId,
                          CreateAssignmentParams(
                            lessonId: lessonSelection.lessonId,
                            title: titleController.text.trim(),
                            description: descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            dueDate: selectedDueDate,
                          ),
                        ),
                      );
                }
              },
              child: const Text('Crear Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentsTab extends StatelessWidget {
  final List<Assignment> assignments;
  final VoidCallback onCreateAssignment;

  const _AssignmentsTab({
    required this.assignments,
    required this.onCreateAssignment,
  });

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text('No hay tareas asignadas'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreateAssignment,
              icon: const Icon(Icons.add),
              label: const Text('Crear Tarea'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.space),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _AssignmentCard(assignment: assignment);
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  assignment.isOverdue ? Icons.warning : Icons.assignment,
                  color: assignment.isOverdue ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assignment.title,
                    style: AppTypography.titleSmall,
                  ),
                ),
                if (assignment.isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Vencida',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            if (assignment.description != null) ...[
              const SizedBox(height: 8),
              Text(
                assignment.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (assignment.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Vence: ${DateFormat('dd/MM/yyyy').format(assignment.dueDate!)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentsTab extends StatelessWidget {
  final String classId;
  final List<StudentProgress>? students;
  final VoidCallback onRefresh;

  const _StudentsTab({
    required this.classId,
    required this.students,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (students == null) {
      // Cargar estudiantes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onRefresh();
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (students!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('No hay estudiantes inscritos'),
            SizedBox(height: 8),
            Text(
              'Comparte el código de clase para que se unan',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.space),
        itemCount: students!.length,
        itemBuilder: (context, index) {
          return _StudentCard(student: students![index]);
        },
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentProgress student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                student.studentName.isNotEmpty
                    ? student.studentName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppDimensions.space),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.studentName, style: AppTypography.titleSmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.check_circle,
                        value: '${student.assignmentsCompleted}/${student.totalAssignments}',
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.percent,
                        value: '${student.averageAccuracy.toInt()}%',
                        color: _getAccuracyColor(student.averageAccuracy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${student.lessonsCompleted}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'lecciones',
                  style: AppTypography.labelSmall,
                ),
              ],
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}
