import 'package:flutter/material.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

/// Página de demostración de animaciones disponibles
class AnimationsDemoPage extends StatefulWidget {
  const AnimationsDemoPage({super.key});

  @override
  State<AnimationsDemoPage> createState() => _AnimationsDemoPageState();
}

class _AnimationsDemoPageState extends State<AnimationsDemoPage> {
  double _progressValue = 0.0;
  int _counterValue = 0;
  bool _isFlipped = false;
  bool _shake = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animaciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space),
        children: [
          // Sección: Animaciones Lottie
          _buildSection(
            title: 'Animaciones Lottie',
            icon: Icons.animation,
            children: [
              const Text(
                'Para usar estas animaciones, descarga archivos .json de LottieFiles y colócalos en assets/animations/',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _LottiePreview(
                    title: 'Loading',
                    child: const LoadingAnimation(size: 80),
                  ),
                  _LottiePreview(
                    title: 'Success',
                    child: const SuccessAnimation(size: 80),
                  ),
                  _LottiePreview(
                    title: 'Streak',
                    child: const StreakAnimation(streakCount: 5, size: 80),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceL),

          // Sección: Contadores y Progreso
          _buildSection(
            title: 'Contadores y Progreso',
            icon: Icons.trending_up,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Contador'),
                        const SizedBox(height: 8),
                        AnimatedCounter(
                          value: _counterValue,
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => setState(() => _counterValue -= 10),
                              icon: const Icon(Icons.remove),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _counterValue += 10),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Circular'),
                        const SizedBox(height: 8),
                        AnimatedCircularProgress(
                          value: _progressValue,
                          size: 80,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Barra de progreso'),
              const SizedBox(height: 8),
              AnimatedProgressBar(
                value: _progressValue,
                height: 12,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _progressValue,
                onChanged: (v) => setState(() => _progressValue = v),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceL),

          // Sección: Animaciones de entrada
          _buildSection(
            title: 'Animaciones de Entrada',
            icon: Icons.visibility,
            children: [
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Reproducir'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnimatedFadeIn(
                      key: UniqueKey(),
                      delay: const Duration(milliseconds: 0),
                      child: _buildCard('Fade In', AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedFadeIn(
                      key: UniqueKey(),
                      delay: const Duration(milliseconds: 200),
                      child: _buildCard('Delay 200ms', AppColors.secondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedBounceIn(
                      key: UniqueKey(),
                      delay: const Duration(milliseconds: 400),
                      child: _buildCard('Bounce', AppColors.success),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceL),

          // Sección: Interacciones
          _buildSection(
            title: 'Interacciones',
            icon: Icons.touch_app,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnimatedPressable(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Presionable',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedPulseButton(
                      onPressed: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Pulso',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnimatedShake(
                      shake: _shake,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Shake',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() => _shake = true);
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (mounted) setState(() => _shake = false);
                      });
                    },
                    icon: const Icon(Icons.vibration),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceL),

          // Sección: Flip Card
          _buildSection(
            title: 'Flip Card',
            icon: Icons.flip,
            children: [
              Center(
                child: SizedBox(
                  width: 200,
                  height: 120,
                  child: AnimatedFlipCard(
                    isFlipped: _isFlipped,
                    onFlip: () => setState(() => _isFlipped = !_isFlipped),
                    front: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '¿Cuál es la seña?',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    back: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '👋 ¡Hola!',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Toca la tarjeta para voltear',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceL),

          // Sección: Lista Animada
          _buildSection(
            title: 'Lista Animada',
            icon: Icons.list,
            children: [
              ...List.generate(5, (index) {
                return AnimatedListItem(
                  key: UniqueKey(),
                  index: index,
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text('${index + 1}'),
                      ),
                      title: Text('Elemento ${index + 1}'),
                      subtitle: const Text('Con animación de entrada'),
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceL),

          // Sección: Shimmer Loading
          _buildSection(
            title: 'Shimmer Loading',
            icon: Icons.hourglass_empty,
            children: [
              Row(
                children: [
                  const AnimatedShimmer(width: 60, height: 60, borderRadius: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        AnimatedShimmer(width: 150, height: 16),
                        SizedBox(height: 8),
                        AnimatedShimmer(width: 100, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AnimatedShimmer(width: double.infinity, height: 100),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceXXL),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _LottiePreview extends StatelessWidget {
  final String title;
  final Widget child;

  const _LottiePreview({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
