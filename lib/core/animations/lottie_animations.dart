import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Rutas de animaciones Lottie
/// Se debe descargar las animaciones de LottieFiles y colocarlas en assets/animations/
class LottieAssets {
  // Animaciones de estado
  static const String loading = 'assets/animations/loading.json';
  static const String success = 'assets/animations/success.json';
  static const String error = 'assets/animations/error.json';
  static const String empty = 'assets/animations/empty.json';
  static const String noConnection = 'assets/animations/no_connection.json';
  
  // Animaciones de logros
  static const String celebration = 'assets/animations/celebration.json';
  static const String star = 'assets/animations/star.json';
  static const String trophy = 'assets/animations/trophy.json';
  static const String levelUp = 'assets/animations/level_up.json';
  static const String streak = 'assets/animations/streak.json';
  
  // Animaciones de aprendizaje
  static const String learning = 'assets/animations/learning.json';
  static const String hands = 'assets/animations/hands.json';
  static const String thinking = 'assets/animations/thinking.json';
  
  // Animaciones de onboarding
  static const String welcome = 'assets/animations/welcome.json';
  static const String teacher = 'assets/animations/teacher.json';
  static const String student = 'assets/animations/student.json';
}

/// Widget de animación Lottie con estados comunes
class LottieAnimation extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool reverse;
  final AnimationController? controller;
  final void Function(LottieComposition)? onLoaded;

  const LottieAnimation({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.controller,
    this.onLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      reverse: reverse,
      controller: controller,
      onLoaded: onLoaded,
      errorBuilder: (context, error, stackTrace) {
        // Fallback si no existe la animación
        return SizedBox(
          width: width ?? 100,
          height: height ?? 100,
          child: const Icon(
            Icons.animation,
            size: 48,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}

/// Animación de carga
class LoadingAnimation extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingAnimation({
    super.key,
    this.size = 150,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LottieAnimation(
          asset: LottieAssets.loading,
          width: size,
          height: size,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Animación de éxito
class SuccessAnimation extends StatefulWidget {
  final double size;
  final String? message;
  final VoidCallback? onComplete;

  const SuccessAnimation({
    super.key,
    this.size = 150,
    this.message,
    this.onComplete,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LottieAnimation(
          asset: LottieAssets.success,
          width: widget.size,
          height: widget.size,
          repeat: false,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Animación de celebración (confeti, estrellas)
class CelebrationAnimation extends StatefulWidget {
  final double size;
  final Widget? child;
  final bool autoPlay;

  const CelebrationAnimation({
    super.key,
    this.size = 200,
    this.child,
    this.autoPlay = true,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.child != null) widget.child!,
        IgnorePointer(
          child: LottieAnimation(
            asset: LottieAssets.celebration,
            width: widget.size,
            height: widget.size,
            repeat: false,
            controller: _controller,
            onLoaded: (composition) {
              _controller.duration = composition.duration;
            },
          ),
        ),
      ],
    );
  }
}

/// Animación de estado vacío
class EmptyStateAnimation extends StatelessWidget {
  final double size;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateAnimation({
    super.key,
    this.size = 200,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieAnimation(
              asset: LottieAssets.empty,
              width: size,
              height: size,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Animación de sin conexión
class NoConnectionAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onRetry;

  const NoConnectionAnimation({
    super.key,
    this.size = 200,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieAnimation(
              asset: LottieAssets.noConnection,
              width: size,
              height: size,
            ),
            const SizedBox(height: 24),
            Text(
              'Sin conexión',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica tu conexión a internet e intenta nuevamente',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animación de racha de fuego
class StreakAnimation extends StatelessWidget {
  final int streakCount;
  final double size;

  const StreakAnimation({
    super.key,
    required this.streakCount,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        LottieAnimation(
          asset: LottieAssets.streak,
          width: size,
          height: size,
        ),
        Positioned(
          bottom: 8,
          child: Text(
            '$streakCount',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
