import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/activity_entities.dart';

/// Widget para juego de memoria
class GameActivityWidget extends StatefulWidget {
  final GameContent gameContent;
  final Function(ActivityResult) onComplete;

  const GameActivityWidget({
    super.key,
    required this.gameContent,
    required this.onComplete,
  });

  @override
  State<GameActivityWidget> createState() => _GameActivityWidgetState();
}

class _GameActivityWidgetState extends State<GameActivityWidget> {
  late List<_GameCard> _cards;
  _GameCard? _firstSelected;
  _GameCard? _secondSelected;
  bool _isChecking = false;
  int _matchedPairs = 0;
  int _moves = 0;
  int _score = 0;
  late Timer _timer;
  int _secondsRemaining = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Crear cartas (cada par tiene una imagen y un texto)
    _cards = [];
    for (final pair in widget.gameContent.pairs) {
      // Carta con imagen
      _cards.add(_GameCard(
        id: '${pair.id}_img',
        pairId: pair.id,
        content: pair.imageUrl ?? pair.word,
        isImage: pair.imageUrl != null,
      ));
      // Carta con texto
      _cards.add(_GameCard(
        id: '${pair.id}_text',
        pairId: pair.id,
        content: pair.word,
        isImage: false,
      ));
    }
    _cards.shuffle(Random());

    _secondsRemaining = widget.gameContent.timeLimit;
    _stopwatch.start();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _endGame(timedOut: true);
      }
    });
  }

  void _onCardTap(_GameCard card) {
    if (_isChecking || card.isMatched || card.isFlipped) return;

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
    } else if (_secondSelected == null && card.id != _firstSelected!.id) {
      _secondSelected = card;
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isChecking = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (_firstSelected!.pairId == _secondSelected!.pairId) {
        // Match!
        setState(() {
          _firstSelected!.isMatched = true;
          _secondSelected!.isMatched = true;
          _matchedPairs++;
          _score += 10;
        });

        if (_matchedPairs == widget.gameContent.pairs.length) {
          _endGame(timedOut: false);
        }
      } else {
        // No match
        setState(() {
          _firstSelected!.isFlipped = false;
          _secondSelected!.isFlipped = false;
        });
      }

      _firstSelected = null;
      _secondSelected = null;
      _isChecking = false;
    });
  }

  void _endGame({required bool timedOut}) {
    _timer.cancel();
    _stopwatch.stop();

    final maxScore = widget.gameContent.points;
    final timeBonus = timedOut ? 0 : (_secondsRemaining * 2);
    final finalScore = _score + timeBonus;

    widget.onComplete(ActivityResult(
      activityId: widget.gameContent.activityId,
      score: finalScore,
      maxScore: maxScore,
      correctAnswers: _matchedPairs,
      totalQuestions: widget.gameContent.pairs.length,
      timeTaken: _stopwatch.elapsed,
      passed: _matchedPairs == widget.gameContent.pairs.length && !timedOut,
    ));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = widget.gameContent.pairs.length <= 4 ? 3 : 4;

    return Column(
      children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.all(AppDimensions.space),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.timer,
                value: _formatTime(_secondsRemaining),
                color: _secondsRemaining < 10 ? AppColors.error : AppColors.primary,
              ),
              _StatItem(
                icon: Icons.touch_app,
                value: '$_moves',
                label: 'Movimientos',
                color: AppColors.secondary,
              ),
              _StatItem(
                icon: Icons.star,
                value: '$_score',
                label: 'Puntos',
                color: AppColors.warning,
              ),
              _StatItem(
                icon: Icons.check_circle,
                value: '$_matchedPairs/${widget.gameContent.pairs.length}',
                label: 'Pares',
                color: AppColors.success,
              ),
            ],
          ),
        ),

        // Game grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppDimensions.spaceS,
                mainAxisSpacing: AppDimensions.spaceS,
                childAspectRatio: 0.8,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return _MemoryCard(
                  card: card,
                  onTap: () => _onCardTap(card),
                );
              },
            ),
          ),
        ),

        // Instructions
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Text(
            'Encuentra los pares de imagen y palabra',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _GameCard {
  final String id;
  final String pairId;
  final String content;
  final bool isImage;
  bool isFlipped;
  bool isMatched;

  _GameCard({
    required this.id,
    required this.pairId,
    required this.content,
    required this.isImage,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _MemoryCard extends StatelessWidget {
  final _GameCard card;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isMatched
              ? AppColors.success.withOpacity(0.2)
              : card.isFlipped
                  ? Colors.white
                  : AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(
            color: card.isMatched
                ? AppColors.success
                : card.isFlipped
                    ? AppColors.primary
                    : AppColors.primary,
            width: 2,
          ),
          boxShadow: card.isFlipped || card.isMatched
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: card.isFlipped || card.isMatched
            ? _buildContent()
            : _buildBack(),
      ),
    );
  }

  Widget _buildBack() {
    return const Center(
      child: Icon(
        Icons.question_mark,
        size: 32,
        color: Colors.white,
      ),
    );
  }

  Widget _buildContent() {
    if (card.isImage && card.content.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radius - 2),
        child: Image.network(
          card.content,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.image_not_supported,
              color: AppColors.textHint,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          card.content,
          style: AppTypography.titleSmall.copyWith(
            color: card.isMatched ? AppColors.success : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(color: color),
            ),
          ],
        ),
        if (label != null)
          Text(
            label!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
