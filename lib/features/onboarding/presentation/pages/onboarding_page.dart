import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/config/routes.dart';
import '../../../../injection_container.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      icon: Icons.waving_hand,
      title: '¡Bienvenido a MinGO!',
      description:
          'Aprende Lengua de Señas Ecuatoriana junto a tu hijo(a) de manera divertida e interactiva.',
      color: AppColors.primary,
      lottieAsset: LottieAssets.welcome,
    ),
    OnboardingStep(
      icon: Icons.school,
      title: 'Aprendizaje por Niveles',
      description:
          'Contenido adaptado a diferentes niveles: Principiante, Intermedio y Avanzado, según tu experiencia.',
      color: AppColors.levelIntermedio,
      lottieAsset: LottieAssets.learning,
    ),
    OnboardingStep(
      icon: Icons.groups,
      title: 'Únete a una Clase',
      description:
          'Conéctate con un docente usando un código de clase para acceder a contenido personalizado y seguimiento.',
      color: AppColors.secondary,
      lottieAsset: LottieAssets.teacher,
    ),
    OnboardingStep(
      icon: Icons.videocam,
      title: 'Practica con Videos',
      description:
          'Aprende señas a través de videos demostrativos y ejercicios interactivos.',
      color: AppColors.success,
      lottieAsset: LottieAssets.hands,
    ),
    OnboardingStep(
      icon: Icons.trending_up,
      title: 'Sigue tu Progreso',
      description:
          'Visualiza tu avance, racha de aprendizaje y las palabras que has dominado.',
      color: AppColors.info,
      lottieAsset: LottieAssets.celebration,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón de omitir
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text('Omitir'),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_steps[index], index);
                },
              ),
            ),

            // Indicadores
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.space),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _steps[_currentPage].color
                          : AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              child: Row(
                children: [
                  // Botón anterior
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.space,
                          ),
                        ),
                        child: const Text('Anterior'),
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: AppDimensions.space),

                  // Botón siguiente/comenzar
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _steps[_currentPage].color,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.space,
                        ),
                      ),
                      child: Text(
                        _currentPage == _steps.length - 1
                            ? '¡Comenzar!'
                            : 'Siguiente',
                      ),
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

  Widget _buildPage(OnboardingStep step, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animación o icono
          AnimatedBounceIn(
            key: ValueKey(index),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: step.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: step.lottieAsset != null
                    ? LottieAnimation(
                        asset: step.lottieAsset!,
                        width: 120,
                        height: 120,
                      )
                    : Icon(
                        step.icon,
                        size: 80,
                        color: step.color,
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXL),

          // Título
          AnimatedFadeIn(
            key: ValueKey('title_$index'),
            delay: const Duration(milliseconds: 200),
            child: Text(
              step.title,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.space),

          // Descripción
          AnimatedFadeIn(
            key: ValueKey('desc_$index'),
            delay: const Duration(milliseconds: 400),
            child: Text(
              step.description,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      // Verificar si necesita hacer la prueba de conocimiento
      final assessmentCompleted = prefs.getBool('assessment_completed') ?? false;
      
      if (!assessmentCompleted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.assessment);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    }
  }
}

class OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? lottieAsset;

  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.lottieAsset,
  });
}
