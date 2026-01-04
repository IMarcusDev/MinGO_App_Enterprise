import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/activity_entities.dart';

/// Widget para mostrar contenido de video de señas
class VideoActivityWidget extends StatefulWidget {
  final List<SignContent> contents;
  final VoidCallback onComplete;

  const VideoActivityWidget({
    super.key,
    required this.contents,
    required this.onComplete,
  });

  @override
  State<VideoActivityWidget> createState() => _VideoActivityWidgetState();
}

class _VideoActivityWidgetState extends State<VideoActivityWidget> {
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _hasWatched = false;

  SignContent get currentContent => widget.contents[_currentIndex];
  bool get isLastContent => _currentIndex >= widget.contents.length - 1;

  void _playVideo() {
    setState(() {
      _isPlaying = true;
    });
    
    // Simular reproducción de video (en producción usar video_player)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _hasWatched = true;
        });
      }
    });
  }

  void _nextContent() {
    if (isLastContent) {
      widget.onComplete();
    } else {
      setState(() {
        _currentIndex++;
        _hasWatched = false;
      });
    }
  }

  void _previousContent() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _hasWatched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            children: List.generate(widget.contents.length, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index <= _currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),

        // Contador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
          child: Text(
            '${_currentIndex + 1} de ${widget.contents.length}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.space),

        // Video area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
            child: Column(
              children: [
                // Video container
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Placeholder o imagen
                        if (currentContent.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                            child: Image.network(
                              currentContent.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            ),
                          )
                        else
                          _buildPlaceholder(),

                        // Play button
                        if (!_isPlaying)
                          GestureDetector(
                            onTap: _playVideo,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                        // Loading indicator
                        if (_isPlaying)
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),

                        // Watched badge
                        if (_hasWatched && !_isPlaying)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Visto',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceL),

                // Word and description
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        currentContent.word,
                        style: AppTypography.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (currentContent.description != null) ...[
                        const SizedBox(height: AppDimensions.spaceS),
                        Text(
                          currentContent.description!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousContent,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: AppDimensions.space),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _hasWatched ? _nextContent : null,
                  icon: Icon(isLastContent ? Icons.check : Icons.arrow_forward),
                  label: Text(isLastContent ? 'Completar' : 'Siguiente'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.sign_language,
          size: 64,
          color: Colors.white54,
        ),
        const SizedBox(height: 8),
        Text(
          currentContent.word,
          style: AppTypography.titleLarge.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}
