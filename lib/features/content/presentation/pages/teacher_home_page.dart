import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../classes/domain/entities/class_entities.dart';
import '../../../classes/presentation/bloc/class_bloc.dart';

/// Home page específica para Docentes
/// 
/// Funcionalidades:
/// - Dashboard con estadísticas generales
/// - Gestión de clases (crear, ver, eliminar)
/// - Ver estudiantes por clase
/// - Importar contenido
/// - Ver progreso de estudiantes
class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassBloc>()..add(const LoadTeacherClassesEvent()),
      child: const _TeacherHomeView(),
    );
  }
}

class _TeacherHomeView extends StatefulWidget {
  const _TeacherHomeView();

  @override
  State<_TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<_TeacherHomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            _DashboardTab(),
            _ClassesTab(),
            _ContentTab(),
            _ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Clases',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_outlined),
          activeIcon: Icon(Icons.library_books),
          label: 'Contenido',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}

// ============================================
// TAB 1: Dashboard
// ============================================

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassBloc>().add(const LoadTeacherClassesEvent());
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.space)),
          SliverToBoxAdapter(child: _buildStatsCards(context)),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spaceL)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spaceL)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
              child: Text('Mis Clases', style: AppTypography.titleLarge),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.space)),
          _buildRecentClasses(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue(200),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXL),
          bottomRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String userName = 'Docente';
          if (state is AuthAuthenticatedState) {
            userName = state.user.name.split(' ').first;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '¡Hola, $userName!',
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('👨‍🏫', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🎓 Panel de Docente',
                          style: AppTypography.labelMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => AppNavigator.pushNamed(AppRoutes.profile),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 22,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        int totalClasses = 0;
        int totalStudents = 0;
        
        if (state is TeacherClassesLoadedState) {
          totalClasses = state.classList.classes.length;
          totalStudents = state.classList.classes.fold(0, (sum, c) => sum + c.studentsCount);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.school,
                  value: totalClasses.toString(),
                  label: 'Clases',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.space),
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  value: totalStudents.toString(),
                  label: 'Estudiantes',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppDimensions.space),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  value: '85%',
                  label: 'Promedio',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Acciones Rápidas', style: AppTypography.titleMedium),
          const SizedBox(height: AppDimensions.space),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Nueva Clase',
                  color: AppColors.primary,
                  onTap: () => _showCreateClassDialog(context),
                ),
              ),
              const SizedBox(width: AppDimensions.space),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.file_upload_outlined,
                  title: 'Importar',
                  color: AppColors.warning,
                  onTap: () => AppNavigator.pushNamed(AppRoutes.importContent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.analytics_outlined,
                  title: 'Reportes',
                  color: AppColors.info,
                  onTap: () => AppNavigator.pushNamed(AppRoutes.progress),
                ),
              ),
              const SizedBox(width: AppDimensions.space),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.library_books_outlined,
                  title: 'Contenido',
                  color: AppColors.success,
                  onTap: () => AppNavigator.pushNamed(AppRoutes.search),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentClasses() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        if (state is ClassLoadingState) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TeacherClassesLoadedState) {
          if (state.classList.classes.isEmpty) {
            return SliverToBoxAdapter(
              child: _buildEmptyClasses(context),
            );
          }

          final classes = state.classList.classes.take(3).toList();
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ClassPreviewCard(
                  schoolClass: classes[index],
                  onTap: () => AppNavigator.pushNamed(
                    AppRoutes.classDetail,
                    arguments: classes[index].id,
                  ),
                ),
                childCount: classes.length,
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildEmptyClasses(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.space),
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.space),
          Text(
            'No tienes clases todavía',
            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'Crea tu primera clase para comenzar a enseñar',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space),
          ElevatedButton.icon(
            onPressed: () => _showCreateClassDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Crear mi primera clase'),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('Nueva Clase'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la clase *',
                hintText: 'Ej: LSEC Básico - Grupo A',
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: AppDimensions.space),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Descripción breve de la clase...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.space),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se generará un código único para que los padres puedan unir a sus hijos.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
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
            icon: const Icon(Icons.check),
            label: const Text('Crear Clase'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// TAB 2: Clases
// ============================================

class _ClassesTab extends StatelessWidget {
  const _ClassesTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppDimensions.space),
          color: AppColors.surface,
          child: Row(
            children: [
              Text('Mis Clases', style: AppTypography.titleLarge),
              const Spacer(),
              IconButton(
                onPressed: () {
                  context.read<ClassBloc>().add(const LoadTeacherClassesEvent());
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        
        // Lista de clases
        Expanded(
          child: BlocConsumer<ClassBloc, ClassState>(
            listener: (context, state) {
              if (state is ClassCreatedState) {
                _showClassCodeDialog(context, state.schoolClass);
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

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
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
              'Crea tu primera clase para empezar a enseñar LSEC',
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
        itemCount: classes.length + 1,
        itemBuilder: (context, index) {
          if (index == classes.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.space),
              child: OutlinedButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Crear nueva clase'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(AppDimensions.space),
                ),
              ),
            );
          }

          return _FullClassCard(
            schoolClass: classes[index],
            onTap: () => AppNavigator.pushNamed(
              AppRoutes.classDetail,
              arguments: classes[index].id,
            ),
            onShare: () => _shareClassCode(context, classes[index]),
            onDelete: () => _confirmDelete(context, classes[index]),
          );
        },
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

  void _showClassCodeDialog(BuildContext context, SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('¡Clase Creada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tu clase "${schoolClass.name}" ha sido creada exitosamente.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Comparte este código con los padres:',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.space),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radius),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    schoolClass.code,
                    style: AppTypography.headlineMedium.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: schoolClass.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado al portapapeles')),
                      );
                    },
                    icon: const Icon(Icons.copy, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: schoolClass.code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado al portapapeles')),
              );
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.share),
            label: const Text('Copiar y Compartir'),
          ),
        ],
      ),
    );
  }

  void _shareClassCode(BuildContext context, SchoolClass schoolClass) {
    Clipboard.setData(ClipboardData(text: schoolClass.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código "${schoolClass.code}" copiado'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _showClassCodeDialog(context, schoolClass),
        ),
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
          'Los ${schoolClass.studentsCount} estudiantes serán removidos de la clase.\n\n'
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

// ============================================
// TAB 3: Contenido
// ============================================

class _ContentTab extends StatelessWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.space),
            color: AppColors.surface,
            child: Text('Gestión de Contenido', style: AppTypography.titleLarge),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppDimensions.space),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _ContentOptionCard(
                icon: Icons.file_upload,
                title: 'Importar Contenido',
                subtitle: 'Sube contenido desde archivos JSON',
                color: AppColors.warning,
                onTap: () => AppNavigator.pushNamed(AppRoutes.importContent),
              ),
              _ContentOptionCard(
                icon: Icons.search,
                title: 'Explorar Contenido',
                subtitle: 'Busca y visualiza señas disponibles',
                color: AppColors.primary,
                onTap: () => AppNavigator.pushNamed(AppRoutes.search),
              ),
              _ContentOptionCard(
                icon: Icons.library_books,
                title: 'Ver Niveles',
                subtitle: 'Revisa los niveles y módulos disponibles',
                color: AppColors.secondary,
                onTap: () => AppNavigator.pushNamed(AppRoutes.parentHome),
              ),
              _ContentOptionCard(
                icon: Icons.front_hand,
                title: 'Práctica de Señas',
                subtitle: 'Prueba el reconocimiento de señas',
                color: AppColors.success,
                onTap: () => AppNavigator.pushNamed(AppRoutes.signPractice),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ============================================
// TAB 4: Perfil
// ============================================

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spaceL),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppDimensions.space),
              Text(user.name, style: AppTypography.titleLarge),
              const SizedBox(height: 4),
              Text(user.email, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '👨‍🏫 Docente',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              
              // Opciones
              _ProfileOption(
                icon: Icons.person,
                title: 'Editar Perfil',
                onTap: () => AppNavigator.pushNamed(AppRoutes.profile),
              ),
              _ProfileOption(
                icon: Icons.notifications,
                title: 'Notificaciones',
                onTap: () => AppNavigator.pushNamed(AppRoutes.notificationSettings),
              ),
              _ProfileOption(
                icon: Icons.palette,
                title: 'Apariencia',
                onTap: () => AppNavigator.pushNamed(AppRoutes.appearanceSettings),
              ),
              _ProfileOption(
                icon: Icons.help,
                title: 'Ayuda',
                onTap: () {},
              ),
              const Divider(height: 32),
              _ProfileOption(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                color: AppColors.error,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutEvent());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGETS AUXILIARES
// ============================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.labelLarge.copyWith(color: color),
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

class _ClassPreviewCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final VoidCallback onTap;

  const _ClassPreviewCard({
    required this.schoolClass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school, color: AppColors.primary),
        ),
        title: Text(schoolClass.name, style: AppTypography.titleSmall),
        subtitle: Text('${schoolClass.studentsCount} estudiantes • ${schoolClass.code}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _FullClassCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _FullClassCard({
    required this.schoolClass,
    required this.onTap,
    required this.onShare,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppDimensions.space),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schoolClass.name, style: AppTypography.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${schoolClass.studentsCount} estudiantes',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'share') onShare();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Compartir código'),
                          ],
                        ),
                      ),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('Código: ', style: AppTypography.bodySmall),
                    Text(
                      schoolClass.code,
                      style: AppTypography.titleSmall.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: schoolClass.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Copiar',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
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

class _ContentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTypography.titleSmall),
        subtitle: Text(subtitle, style: AppTypography.bodySmall),
        trailing: Icon(Icons.chevron_right, color: color),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c),
      title: Text(title, style: AppTypography.bodyMedium.copyWith(color: c)),
      trailing: Icon(Icons.chevron_right, color: c.withOpacity(0.5)),
    );
  }
}
