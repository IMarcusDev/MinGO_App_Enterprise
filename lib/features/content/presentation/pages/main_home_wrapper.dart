import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'home_page.dart';
import 'teacher_home_page.dart';

/// Wrapper que decide qué home mostrar según el rol del usuario
/// 
/// - PADRE: Muestra HomePage (aprendizaje, mis hijos, progreso)
/// - DOCENTE: Muestra TeacherHomePage (clases, estudiantes, importar)
/// - ADMIN: Muestra TeacherHomePage (mismas funciones que docente por ahora)
class MainHomeWrapper extends StatelessWidget {
  const MainHomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) {
          // Si no está autenticado, mostrar loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = state.user;
        
        // Decidir qué home mostrar según el rol
        switch (user.role) {
          case UserRole.docente:
          case UserRole.admin:
            return const TeacherHomePage();
          
          case UserRole.padre:
          default:
            return const HomePage();
        }
      },
    );
  }
}

/// Widget auxiliar para mostrar el rol actual (debug)
class RoleBadge extends StatelessWidget {
  final UserRole role;
  
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (role) {
      UserRole.padre => (Colors.blue, Icons.family_restroom, 'Padre'),
      UserRole.docente => (Colors.green, Icons.school, 'Docente'),
      UserRole.admin => (Colors.purple, Icons.admin_panel_settings, 'Admin'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
