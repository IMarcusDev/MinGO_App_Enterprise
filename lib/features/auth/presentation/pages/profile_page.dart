import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // TODO: Configuraciones
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceXL),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user.profilePicUrl != null
                      ? NetworkImage(user.profilePicUrl!)
                      : null,
                  child: user.profilePicUrl == null
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: AppTypography.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: AppDimensions.space),
                
                // Nombre
                Text(user.name, style: AppTypography.headlineSmall),
                const SizedBox(height: AppDimensions.spaceXS),
                
                // Email
                Text(
                  user.email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                
                // Badge de rol
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceM,
                    vertical: AppDimensions.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    user.role.value,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                // Badge de verificación
                if (user.emailVerified) ...[
                  const SizedBox(height: AppDimensions.spaceS),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Email verificado',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: AppDimensions.spaceXXL),
                
                // Opciones
                _ProfileOption(
                  icon: Icons.child_care,
                  title: 'Mis hijos',
                  subtitle: 'Administrar perfiles de hijos',
                  onTap: () => AppNavigator.pushNamed(AppRoutes.children),
                ),
                _ProfileOption(
                  icon: Icons.bar_chart,
                  title: 'Mi progreso',
                  subtitle: 'Ver estadísticas de aprendizaje',
                  onTap: () => AppNavigator.pushNamed(AppRoutes.progress),
                ),
                _ProfileOption(
                  icon: Icons.workspace_premium,
                  title: 'Suscripción',
                  subtitle: 'Plan FREE',
                  onTap: () {
                    // TODO: Suscripciones
                  },
                ),
                _ProfileOption(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  subtitle: 'Recordatorios y alertas',
                  onTap: () => AppNavigator.pushNamed(AppRoutes.notificationSettings),
                ),
                _ProfileOption(
                  icon: Icons.palette_outlined,
                  title: 'Apariencia',
                  subtitle: 'Tema claro u oscuro',
                  onTap: () => AppNavigator.pushNamed(AppRoutes.appearanceSettings),
                ),
                
                const Divider(height: AppDimensions.spaceXXL),
                
                _ProfileOption(
                  icon: Icons.help_outline,
                  title: 'Ayuda',
                  onTap: () {},
                ),
                _ProfileOption(
                  icon: Icons.info_outline,
                  title: 'Acerca de',
                  onTap: () {},
                ),
                
                const SizedBox(height: AppDimensions.spaceXL),
                
                // Cerrar sesión
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar sesión'),
                        content: const Text('¿Estás seguro que deseas salir?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(const AuthLogoutEvent());
                              AppNavigator.goToLogin();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: const Text('Cerrar sesión'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    'Cerrar sesión',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.bodySmall)
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
