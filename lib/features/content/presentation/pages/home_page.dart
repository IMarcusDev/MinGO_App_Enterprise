import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/content_entities.dart';
import '../bloc/content_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContentBloc>()..add(const LoadLevelSectionsEvent()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ContentBloc>().add(const LoadLevelSectionsEvent());
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space),
                  child: _buildQuickActions(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
                  child: Text('Niveles', style: AppTypography.titleLarge),
                ),
              ),
              BlocBuilder<ContentBloc, ContentState>(
                builder: (context, state) {
                  if (state is ContentLoadingState) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spaceXL),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (state is ContentErrorState) {
                    return SliverToBoxAdapter(
                      child: _buildError(context, state.message),
                    );
                  }
                  if (state is LevelSectionsLoadedState) {
                    return _buildLevelsList(state.levels);
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildLevelsList(List<LevelSection> levels) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.space),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final level = levels[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space),
              child: _LevelCard(
                level: level,
                onTap: level.isUnlocked
                    ? () => AppNavigator.pushNamed(
                          AppRoutes.levelDetail,
                          arguments: {'levelId': level.id, 'levelName': level.name},
                        )
                    : null,
              ),
            );
          },
          childCount: levels.length,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXL),
          bottomRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String userName = 'Usuario';
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
                      Text('¡Hola, $userName! 👋',
                          style: AppTypography.headlineSmall.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('¿Listo para aprender?',
                          style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => AppNavigator.pushNamed(AppRoutes.profile),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text('🤟', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceL),
              GestureDetector(
                onTap: () => AppNavigator.pushNamed(AppRoutes.search),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('Buscar señas...',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.play_circle_fill,
            title: 'Continuar',
            color: AppColors.primary,
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppDimensions.space),
        Expanded(
          child: _ActionCard(
            icon: Icons.child_care,
            title: 'Mis hijos',
            color: AppColors.secondary,
            onTap: () => AppNavigator.pushNamed(AppRoutes.children),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceXL),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppDimensions.space),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.space),
          ElevatedButton(
            onPressed: () => context.read<ContentBloc>().add(const LoadLevelSectionsEvent()),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        setState(() => _currentIndex = i);
        if (i == 1) AppNavigator.pushNamed(AppRoutes.search);
        if (i == 2) AppNavigator.pushNamed(AppRoutes.progress);
        if (i == 3) AppNavigator.pushNamed(AppRoutes.profile);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progreso'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.labelLarge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelSection level;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, this.onTap});

  Color get _color => AppColors.getLevelColor(level.level.value);

  @override
  Widget build(BuildContext context) {
    final locked = !level.isUnlocked;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space),
        decoration: BoxDecoration(
          color: locked ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(color: locked ? AppColors.border : _color),
          boxShadow: locked ? null : [BoxShadow(color: _color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: locked ? AppColors.border : _color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(locked ? Icons.lock : Icons.school, color: locked ? AppColors.textHint : _color, size: 30),
            ),
            const SizedBox(width: AppDimensions.space),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.name, style: AppTypography.titleMedium.copyWith(color: locked ? AppColors.textHint : AppColors.textPrimary)),
                  if (level.description != null) ...[
                    const SizedBox(height: 4),
                    Text(level.description!, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Icon(locked ? Icons.lock : Icons.chevron_right, color: locked ? AppColors.textHint : _color),
          ],
        ),
      ),
    );
  }
}
