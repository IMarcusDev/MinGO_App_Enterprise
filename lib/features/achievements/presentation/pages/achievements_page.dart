import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/achievement_entities.dart';
import '../bloc/achievement_bloc.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AchievementBloc>()..add(const LoadAchievementsEvent()),
      child: const _AchievementsView(),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  const _AchievementsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
        actions: [
          BlocBuilder<AchievementBloc, AchievementState>(
            builder: (context, state) {
              if (state is AchievementLoadedState) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceM,
                        vertical: AppDimensions.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${state.summary.totalPoints}',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AchievementBloc, AchievementState>(
        builder: (context, state) {
          if (state is AchievementLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AchievementErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppDimensions.space),
                  Text(state.message),
                  const SizedBox(height: AppDimensions.space),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AchievementBloc>().add(const LoadAchievementsEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is AchievementLoadedState) {
            return _buildAchievementsList(context, state.summary);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context, AchievementsSummary summary) {
    return CustomScrollView(
      slivers: [
        // Header con estadísticas
        SliverToBoxAdapter(
          child: _buildStatsHeader(summary),
        ),

        // Tabs por categoría
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: Text(
              'Todos los logros',
              style: AppTypography.titleMedium,
            ),
          ),
        ),

        // Lista de logros por categoría
        for (final category in AchievementCategory.values) ...[
          SliverToBoxAdapter(
            child: _buildCategoryHeader(category, summary),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: AppDimensions.spaceM,
                mainAxisSpacing: AppDimensions.spaceM,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final categoryAchievements = summary.achievements
                      .where((a) => a.achievement.category == category)
                      .toList();
                  if (index >= categoryAchievements.length) return null;
                  return _AchievementCard(progress: categoryAchievements[index]);
                },
                childCount: summary.achievements
                    .where((a) => a.achievement.category == category)
                    .length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceL),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsHeader(AchievementsSummary summary) {
    final percentage = (summary.completionPercentage * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.all(AppDimensions.space),
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: '${summary.unlockedCount}/${summary.totalAchievements}',
                label: 'Desbloqueados',
                icon: '🏆',
              ),
              _StatItem(
                value: '$percentage%',
                label: 'Completado',
                icon: '📊',
              ),
              _StatItem(
                value: '${summary.totalPoints}',
                label: 'Puntos',
                icon: '⭐',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            child: LinearProgressIndicator(
              value: summary.completionPercentage,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(AchievementCategory category, AchievementsSummary summary) {
    final categoryAchievements = summary.achievements
        .where((a) => a.achievement.category == category)
        .toList();
    final unlockedCount = categoryAchievements.where((a) => a.isUnlocked).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space,
        AppDimensions.spaceS,
        AppDimensions.space,
        AppDimensions.spaceS,
      ),
      child: Row(
        children: [
          Text(
            _getCategoryIcon(category),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: AppDimensions.spaceS),
          Text(
            category.displayName,
            style: AppTypography.titleSmall,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              '$unlockedCount/${categoryAchievements.length}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.lessons:
        return '📚';
      case AchievementCategory.streaks:
        return '🔥';
      case AchievementCategory.perfectScores:
        return '🎯';
      case AchievementCategory.modules:
        return '📦';
      case AchievementCategory.milestones:
        return '🏁';
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementProgress progress;

  const _AchievementCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final achievement = progress.achievement;
    final isUnlocked = progress.isUnlocked;

    return Card(
      elevation: isUnlocked ? 4 : 1,
      color: isUnlocked ? null : Colors.grey[200],
      child: InkWell(
        onTap: () => _showAchievementDetails(context),
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono con efecto
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isUnlocked)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getTierColor(achievement.tier).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 40,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                  if (!isUnlocked)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceS),

              // Título
              Text(
                achievement.title,
                style: AppTypography.labelLarge.copyWith(
                  color: isUnlocked ? null : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getTierColor(achievement.tier).withValues(alpha: 0.2)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  '${achievement.tier.emoji} ${achievement.tier.displayName}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isUnlocked ? _getTierColor(achievement.tier) : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),

              // Progreso o puntos
              if (isUnlocked)
                Text(
                  '+${achievement.points} pts',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.percentComplete,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTierColor(achievement.tier),
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.currentProgress}/${progress.requiredProgress}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.grey,
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

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFF00CED1);
    }
  }

  void _showAchievementDetails(BuildContext context) {
    final achievement = progress.achievement;
    final isUnlocked = progress.isUnlocked;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppDimensions.space),
            Text(
              achievement.title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceM,
                vertical: AppDimensions.spaceXS,
              ),
              decoration: BoxDecoration(
                color: _getTierColor(achievement.tier).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                '${achievement.tier.emoji} ${achievement.tier.displayName}',
                style: AppTypography.labelMedium.copyWith(
                  color: _getTierColor(achievement.tier),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space),
            Text(
              achievement.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  '${achievement.points} puntos',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space),
            if (isUnlocked && progress.unlockedAt != null)
              Text(
                'Desbloqueado el ${_formatDate(progress.unlockedAt!)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              )
            else
              Column(
                children: [
                  Text(
                    'Progreso: ${progress.currentProgress}/${progress.requiredProgress}',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.spaceS),
                  LinearProgressIndicator(
                    value: progress.percentComplete,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTierColor(achievement.tier),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppDimensions.spaceL),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
