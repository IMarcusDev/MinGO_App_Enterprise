import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/config/routes.dart';
import '../../data/assessment_questions.dart';
import '../bloc/assessment_bloc.dart';

class AssessmentResultPage extends StatelessWidget {
  const AssessmentResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssessmentBloc, AssessmentState>(
      builder: (context, state) {
        final result = state.result;
        if (result == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.spaceL),

                  // Animación de éxito
                  const SuccessAnimation(
                    size: 150,
                    message: '¡Prueba Completada!',
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  // Tarjeta de nivel asignado
                  AnimatedBounceIn(
                    delay: const Duration(milliseconds: 300),
                    child: _buildLevelCard(context, result.assignedLevel),
                  ),
                  const SizedBox(height: AppDimensions.space),

                  // Puntaje
                  AnimatedFadeIn(
                    delay: const Duration(milliseconds: 500),
                    child: _buildScoreCard(context, result),
                  ),
                  const SizedBox(height: AppDimensions.space),

                  // Categoría de edad
                  AnimatedFadeIn(
                    delay: const Duration(milliseconds: 700),
                    child: _buildAgeCategoryCard(context, result),
                  ),
                  const SizedBox(height: AppDimensions.space),

                  // Mensaje motivacional
                  AnimatedFadeIn(
                    delay: const Duration(milliseconds: 900),
                    child: _buildMotivationalMessage(context, result.assignedLevel),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),

                  // Botón de continuar
                  AnimatedFadeIn(
                    delay: const Duration(milliseconds: 1100),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navegar a enlazar clase o home
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.joinClass,
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continuar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.space,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space),

                  // Botón secundario
                  AnimatedFadeIn(
                    delay: const Duration(milliseconds: 1200),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                      child: const Text('Ir al inicio'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, String level) {
    Color levelColor;
    IconData levelIcon;

    switch (level) {
      case 'Principiante':
        levelColor = AppColors.levelPrincipiante;
        levelIcon = Icons.star_outline;
        break;
      case 'Intermedio':
        levelColor = AppColors.levelIntermedio;
        levelIcon = Icons.star_half;
        break;
      case 'Avanzado':
        levelColor = AppColors.levelAvanzado;
        levelIcon = Icons.star;
        break;
      default:
        levelColor = AppColors.primary;
        levelIcon = Icons.school;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor, levelColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(levelIcon, size: 48, color: Colors.white),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'Tu nivel es',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            level,
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Row(
          children: [
            AnimatedCircularProgress(
              value: result.percentage / 100,
              size: 80,
              foregroundColor: AppColors.primary,
              child: Text(
                '${result.totalScore}',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Puntaje obtenido',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.totalScore} de ${result.maxPossibleScore} puntos',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedProgressBar(
                    value: result.percentage / 100,
                    height: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeCategoryCard(BuildContext context, result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.child_care,
                color: AppColors.secondary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppDimensions.space),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edad de tu hijo(a): ${result.childAge} ${result.childAge == 1 ? "año" : "años"}',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Categoría: ${result.ageCategory}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AssessmentQuestions.getAgeCategoryDescription(result.childAge),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalMessage(BuildContext context, String level) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AssessmentQuestions.getMotivationalMessage(level),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
