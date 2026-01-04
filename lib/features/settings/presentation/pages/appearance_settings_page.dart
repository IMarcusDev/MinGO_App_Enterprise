import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/theme_bloc.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apariencia'),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.space),
            children: [
              // Preview del tema
              _ThemePreview(isDark: state.isDarkMode),
              
              const SizedBox(height: AppDimensions.spaceL),
              
              // Opciones de tema
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tema',
                            style: AppTypography.titleSmall.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    _ThemeOption(
                      icon: Icons.brightness_auto,
                      title: 'Automático',
                      subtitle: 'Seguir configuración del sistema',
                      isSelected: state.isSystemMode,
                      onTap: () => context.read<ThemeBloc>().add(
                        const SetThemeModeEvent(ThemeMode.system),
                      ),
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.light_mode,
                      title: 'Tema claro',
                      subtitle: 'Siempre usar tema claro',
                      isSelected: state.isLightMode,
                      onTap: () => context.read<ThemeBloc>().add(
                        const SetThemeModeEvent(ThemeMode.light),
                      ),
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.dark_mode,
                      title: 'Tema oscuro',
                      subtitle: 'Siempre usar tema oscuro',
                      isSelected: state.isDarkMode,
                      onTap: () => context.read<ThemeBloc>().add(
                        const SetThemeModeEvent(ThemeMode.dark),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppDimensions.space),
              
              // Toggle rápido
              Card(
                child: ListTile(
                  leading: Icon(
                    state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Cambio rápido'),
                  subtitle: Text(
                    state.isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                  ),
                  trailing: Switch(
                    value: state.isDarkMode,
                    onChanged: (_) => context.read<ThemeBloc>().add(
                      const ToggleThemeEvent(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),
              
              // Info
              Container(
                padding: const EdgeInsets.all(AppDimensions.space),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spaceS),
                    Expanded(
                      child: Text(
                        'El tema oscuro es más cómodo para los ojos en ambientes con poca luz y puede ayudar a ahorrar batería',
                        style: AppTypography.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final bool isDark;

  const _ThemePreview({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        gradient: AppColors.headerGradient,
      ),
      child: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Contenido
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    key: ValueKey(isDark),
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.space),
                Text(
                  isDark ? 'Modo Oscuro' : 'Modo Claro',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDark 
                      ? 'Ideal para ambientes oscuros' 
                      : 'Perfecto para el día',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : Icon(
              Icons.circle_outlined,
              color: Theme.of(context).colorScheme.outline,
            ),
      onTap: onTap,
    );
  }
}
