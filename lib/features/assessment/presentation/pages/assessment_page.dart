import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/config/routes.dart';
import '../../data/assessment_questions.dart';
import '../bloc/assessment_bloc.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  @override
  void initState() {
    super.initState();
    context.read<AssessmentBloc>().add(const StartAssessmentEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AssessmentBloc, AssessmentState>(
        listener: (context, state) {
          if (state.status == AssessmentStatus.completed) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.assessmentResult,
            );
          }
          if (state.status == AssessmentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error desconocido'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Header con progreso
                _buildHeader(context, state),

                // Contenido de la pregunta
                Expanded(
                  child: state.isAgeQuestion
                      ? _buildAgeQuestion(context, state)
                      : _buildQuestion(context, state),
                ),

                // Botones de navegación
                _buildNavigationButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AssessmentState state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(Icons.close),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Prueba de Conocimiento',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paso ${state.currentStep + 1} de ${state.totalSteps}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Balance con el botón de cerrar
            ],
          ),
          const SizedBox(height: AppDimensions.spaceS),
          AnimatedProgressBar(
            value: state.progress,
            height: 8,
            foregroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAgeQuestion(BuildContext context, AssessmentState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      child: AnimatedFadeIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono decorativo
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.child_care,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),

            // Categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Edad del hijo/hija',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space),

            // Pregunta
            Text(
              '¿Qué edad tiene su hijo o hija con discapacidad auditiva?',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'Esta información nos ayudará a personalizar el contenido educativo.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXL),

            // Selector de edad
            Center(
              child: Column(
                children: [
                  Text(
                    '${state.childAge == 0 ? "-" : state.childAge}',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    state.childAge == 1 ? 'año' : 'años',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space),

            // Slider
            Slider(
              value: state.childAge.toDouble(),
              min: 0,
              max: 12,
              divisions: 12,
              activeColor: AppColors.primary,
              onChanged: (value) {
                context.read<AssessmentBloc>().add(
                      SetChildAgeEvent(value.toInt()),
                    );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 año', style: AppTypography.bodySmall),
                Text('12 años', style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceL),

            // Categoría resultante
            if (state.childAge > 0)
              AnimatedFadeIn(
                child: Card(
                  color: AppColors.info.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categoría: ${AssessmentQuestions.getAgeCategory(state.childAge)}',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AssessmentQuestions.getAgeCategoryDescription(
                                    state.childAge),
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, AssessmentState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final selectedAnswer = state.answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      child: AnimatedFadeIn(
        key: ValueKey(question.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question.category,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space),

            // Pregunta
            Text(
              question.question,
              style: AppTypography.headlineSmall,
            ),

            if (question.helpText != null) ...[
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                question.helpText!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spaceL),

            // Opciones
            ...List.generate(question.options.length, (index) {
              final option = question.options[index];
              final isSelected = selectedAnswer?.selectedOptionIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
                child: AnimatedPressable(
                  onTap: () {
                    context.read<AssessmentBloc>().add(
                          AnswerQuestionEvent(
                            questionId: question.id,
                            selectedOptionIndex: index,
                            score: option.score,
                          ),
                        );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppDimensions.space),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option.text,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, AssessmentState state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón anterior
          if (state.currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context
                      .read<AssessmentBloc>()
                      .add(const PreviousQuestionEvent());
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimensions.space),
                ),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: AppDimensions.space),

          // Botón siguiente/finalizar
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: state.canProceed
                  ? () {
                      context
                          .read<AssessmentBloc>()
                          .add(const NextQuestionEvent());
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.space),
              ),
              child: state.status == AssessmentStatus.submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.isLastQuestion ? 'Finalizar' : 'Siguiente'),
                        const SizedBox(width: 8),
                        Icon(state.isLastQuestion
                            ? Icons.check
                            : Icons.arrow_forward),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la prueba?'),
        content: const Text(
          'Si sales ahora, perderás tu progreso y deberás comenzar de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
