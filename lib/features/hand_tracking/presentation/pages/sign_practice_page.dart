import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/datasources/sign_comparison_service.dart';
import '../../data/sign_templates.dart';
import '../../domain/entities/hand_landmark_entities.dart';
import '../../domain/entities/sign_template_entities.dart';
import '../bloc/hand_tracking_bloc.dart';
import '../widgets/hand_landmarks_overlay.dart';

class SignPracticePage extends StatefulWidget {
  final SignTemplate? initialSign;
  const SignPracticePage({super.key, this.initialSign});

  @override
  State<SignPracticePage> createState() => _SignPracticePageState();
}

class _SignPracticePageState extends State<SignPracticePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Simulación de mano (para testing sin MediaPipe)
  bool _simulationMode = true;
  HandTrackingFrame? _simulatedFrame;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Inicializar hand tracking
    context.read<HandTrackingBloc>().add(const InitializeHandTrackingEvent());
    
    if (widget.initialSign != null) {
      context.read<HandTrackingBloc>().add(SetTargetSignEvent(widget.initialSign!));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    context.read<HandTrackingBloc>().add(const StopTrackingEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Práctica de Señas'),
        actions: [
          IconButton(
            onPressed: () => _showSignSelector(context),
            icon: const Icon(Icons.list),
            tooltip: 'Seleccionar seña',
          ),
          IconButton(
            onPressed: () => setState(() => _simulationMode = !_simulationMode),
            icon: Icon(_simulationMode ? Icons.play_arrow : Icons.pause),
            tooltip: _simulationMode ? 'Modo real' : 'Modo simulación',
          ),
        ],
      ),
      body: BlocBuilder<HandTrackingBloc, HandTrackingState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Área de cámara / simulación
              Positioned.fill(
                child: _simulationMode 
                    ? _buildSimulationArea(state)
                    : _buildCameraArea(state),
              ),

              // Overlay de landmarks
              if (state.currentFrame != null || _simulatedFrame != null)
                Positioned.fill(
                  child: HandLandmarksOverlay(
                    frame: _simulatedFrame ?? state.currentFrame ?? HandTrackingFrame.empty(),
                    previewSize: MediaQuery.of(context).size,
                  ),
                ),

              // Panel superior - Seña objetivo
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTargetSignPanel(state),
              ),

              // Panel inferior - Feedback y controles
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildControlPanel(state),
              ),

              // Score indicator
              if (state.matchResult != null)
                Positioned(
                  top: 140,
                  right: 16,
                  child: MatchScoreIndicator(
                    score: state.matchResult!.overallScore,
                    isMatch: state.matchResult!.isMatch,
                  ),
                ),

              // Gesto detectado (sin seña objetivo)
              if (state.detectedGesture != null && state.targetSign == null)
                Positioned(
                  top: 140,
                  left: 16,
                  child: _buildGestureIndicator(state.detectedGesture!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSimulationArea(HandTrackingState state) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Simular movimiento de la mano
        _updateSimulatedHand(details.localPosition, MediaQuery.of(context).size);
      },
      child: Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 64, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Modo Simulación',
                style: AppTypography.titleMedium.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca y arrastra para simular la mano',
                style: AppTypography.bodySmall.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraArea(HandTrackingState state) {
    if (!state.isMediaPipeAvailable) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Cámara no disponible',
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Usa el modo simulación para practicar',
                style: AppTypography.bodySmall.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _simulationMode = true),
                child: const Text('Activar simulación'),
              ),
            ],
          ),
        ),
      );
    }

    // Aquí iría el widget de cámara real (CameraPreview)
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text('Vista de cámara', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTargetSignPanel(HandTrackingState state) {
    final sign = state.targetSign;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: sign == null
            ? _buildNoSignSelected()
            : _buildSignInfo(sign, state.matchResult),
      ),
    );
  }

  Widget _buildNoSignSelected() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selecciona una seña para practicar',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => _showSignSelector(context),
            child: const Text('Seleccionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInfo(SignTemplate sign, SignMatchResult? result) {
    return Row(
      children: [
        // Imagen/icono de la seña
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: result?.isMatch == true ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: result?.isMatch == true 
                      ? AppColors.success.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: result?.isMatch == true ? AppColors.success : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    sign.name,
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),

        // Info de la seña
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sign.name,
                style: AppTypography.titleLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                sign.description,
                style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildBadge(sign.category, AppColors.primary),
                  const SizedBox(width: 8),
                  _buildBadge(sign.difficulty.displayName, _difficultyColor(sign.difficulty)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }

  Color _difficultyColor(SignDifficulty d) => switch(d) {
    SignDifficulty.beginner => AppColors.success,
    SignDifficulty.intermediate => AppColors.warning,
    SignDifficulty.advanced => AppColors.error,
  };

  Widget _buildControlPanel(HandTrackingState state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Feedback
            if (state.matchResult != null)
              _buildFeedback(state.matchResult!),

            const SizedBox(height: 16),

            // Indicador de dedos
            if (state.currentFrame?.hasHands == true || _simulatedFrame?.hasHands == true)
              FingerStatusIndicator(
                hand: _simulatedFrame?.rightHand ?? state.currentFrame?.rightHand,
              ),

            const SizedBox(height: 16),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.skip_previous,
                  label: 'Anterior',
                  onPressed: () => _previousSign(),
                ),
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Reintentar',
                  onPressed: () => _resetPractice(),
                  isPrimary: true,
                ),
                _buildControlButton(
                  icon: Icons.skip_next,
                  label: 'Siguiente',
                  onPressed: () => _nextSign(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(SignMatchResult result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.isMatch 
            ? AppColors.success.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isMatch ? AppColors.success : Colors.white24,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                result.isMatch ? Icons.celebration : Icons.tips_and_updates,
                color: result.isMatch ? AppColors.success : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                result.matchLevel.message,
                style: AppTypography.titleSmall.copyWith(
                  color: result.isMatch ? AppColors.success : Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                result.matchLevel.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          if (result.feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...result.feedback.take(2).map((f) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      f,
                      style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildGestureIndicator(BasicGesture gesture) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(gesture.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 8),
          Text(
            gesture.name,
            style: AppTypography.titleMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: isPrimary ? AppColors.primary : Colors.white24,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  void _updateSimulatedHand(Offset position, Size screenSize) {
    final normalizedX = position.dx / screenSize.width;
    final normalizedY = position.dy / screenSize.height;

    // Generar landmarks simulados basados en la posición del dedo
    final landmarks = List.generate(21, (i) {
      final baseX = normalizedX + (i % 5) * 0.03 - 0.06;
      final baseY = normalizedY + (i ~/ 5) * 0.04 - 0.08;
      return HandLandmark(
        index: i,
        x: baseX.clamp(0.0, 1.0),
        y: baseY.clamp(0.0, 1.0),
        z: 0.0,
      );
    });

    final hand = HandDetectionResult(
      landmarks: landmarks,
      handedness: Handedness.right,
      confidence: 0.95,
      timestamp: DateTime.now(),
    );

    setState(() {
      _simulatedFrame = HandTrackingFrame(
        hands: [hand],
        frameNumber: DateTime.now().millisecondsSinceEpoch,
        timestamp: DateTime.now(),
      );
    });

    // Enviar frame al bloc para procesamiento
    context.read<HandTrackingBloc>().add(FrameReceivedEvent(_simulatedFrame!));
  }

  void _showSignSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SignSelectorSheet(
        onSignSelected: (sign) {
          context.read<HandTrackingBloc>().add(SetTargetSignEvent(sign));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _previousSign() {
    final signs = SignTemplates.all;
    final current = context.read<HandTrackingBloc>().state.targetSign;
    if (current == null) return;
    
    final currentIndex = signs.indexWhere((s) => s.id == current.id);
    final prevIndex = (currentIndex - 1 + signs.length) % signs.length;
    context.read<HandTrackingBloc>().add(SetTargetSignEvent(signs[prevIndex]));
  }

  void _nextSign() {
    final signs = SignTemplates.all;
    final current = context.read<HandTrackingBloc>().state.targetSign;
    if (current == null) {
      context.read<HandTrackingBloc>().add(SetTargetSignEvent(signs.first));
      return;
    }
    
    final currentIndex = signs.indexWhere((s) => s.id == current.id);
    final nextIndex = (currentIndex + 1) % signs.length;
    context.read<HandTrackingBloc>().add(SetTargetSignEvent(signs[nextIndex]));
  }

  void _resetPractice() {
    setState(() => _simulatedFrame = null);
  }
}

// ============================================
// Selector de señas
// ============================================

class _SignSelectorSheet extends StatefulWidget {
  final Function(SignTemplate) onSignSelected;
  const _SignSelectorSheet({required this.onSignSelected});

  @override
  State<_SignSelectorSheet> createState() => _SignSelectorSheetState();
}

class _SignSelectorSheetState extends State<_SignSelectorSheet> {
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final categories = ['Todos', ...SignTemplates.categories];
    final signs = _selectedCategory == 'Todos'
        ? SignTemplates.all
        : SignTemplates.getByCategory(_selectedCategory);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('Seleccionar seña', style: AppTypography.titleLarge),
                    const Spacer(),
                    Text('${signs.length} disponibles', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Categorías
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final selected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),

              // Lista de señas
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: signs.length,
                  itemBuilder: (_, i) {
                    final sign = signs[i];
                    return ListTile(
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            sign.name.substring(0, math.min(2, sign.name.length)),
                            style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      title: Text(sign.name),
                      subtitle: Text(sign.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () => widget.onSignSelected(sign),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
