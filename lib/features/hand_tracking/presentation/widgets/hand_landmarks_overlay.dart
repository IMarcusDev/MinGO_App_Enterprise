import 'package:flutter/material.dart';

import '../../domain/entities/hand_landmark_entities.dart';

/// Widget que dibuja los landmarks de la mano sobre la cámara
class HandLandmarksOverlay extends StatelessWidget {
  final HandTrackingFrame frame;
  final Size previewSize;
  final bool showConnections;
  final bool showLabels;
  final Color landmarkColor;
  final Color connectionColor;

  const HandLandmarksOverlay({
    super.key,
    required this.frame,
    required this.previewSize,
    this.showConnections = true,
    this.showLabels = false,
    this.landmarkColor = Colors.green,
    this.connectionColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: previewSize,
      painter: _HandLandmarksPainter(
        frame: frame,
        showConnections: showConnections,
        showLabels: showLabels,
        landmarkColor: landmarkColor,
        connectionColor: connectionColor,
      ),
    );
  }
}

class _HandLandmarksPainter extends CustomPainter {
  final HandTrackingFrame frame;
  final bool showConnections;
  final bool showLabels;
  final Color landmarkColor;
  final Color connectionColor;

  static const List<List<int>> connections = [
    [0, 1], [1, 2], [2, 3], [3, 4],
    [0, 5], [5, 6], [6, 7], [7, 8],
    [0, 9], [9, 10], [10, 11], [11, 12],
    [0, 13], [13, 14], [14, 15], [15, 16],
    [0, 17], [17, 18], [18, 19], [19, 20],
    [5, 9], [9, 13], [13, 17],
  ];

  _HandLandmarksPainter({
    required this.frame,
    required this.showConnections,
    required this.showLabels,
    required this.landmarkColor,
    required this.connectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final hand in frame.hands) {
      _drawHand(canvas, size, hand);
    }
  }

  void _drawHand(Canvas canvas, Size size, HandDetectionResult hand) {
    final landmarks = hand.landmarks;
    if (landmarks.isEmpty) return;

    final color = hand.handedness == Handedness.left ? Colors.orange : landmarkColor;
    final pointPaint = Paint()..color = color..strokeWidth = 8..strokeCap = StrokeCap.round;
    final linePaint = Paint()..color = connectionColor.withOpacity(0.7)..strokeWidth = 3;

    if (showConnections) {
      for (final conn in connections) {
        if (conn[0] < landmarks.length && conn[1] < landmarks.length) {
          final s = landmarks[conn[0]];
          final e = landmarks[conn[1]];
          canvas.drawLine(
            Offset(s.x * size.width, s.y * size.height),
            Offset(e.x * size.width, e.y * size.height),
            linePaint,
          );
        }
      }
    }

    for (final lm in landmarks) {
      final pt = Offset(lm.x * size.width, lm.y * size.height);
      canvas.drawCircle(pt, 6, pointPaint);
      canvas.drawCircle(pt, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _HandLandmarksPainter old) => old.frame != frame;
}

/// Indicador de estado de dedos
class FingerStatusIndicator extends StatelessWidget {
  final HandDetectionResult? hand;
  const FingerStatusIndicator({super.key, this.hand});

  @override
  Widget build(BuildContext context) {
    if (hand == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: Finger.values.map((f) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: hand!.isFingerExtended(f) ? Colors.green : Colors.red.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(_emoji(f), style: const TextStyle(fontSize: 14))),
          ),
        )).toList(),
      ),
    );
  }

  String _emoji(Finger f) => switch(f) {
    Finger.thumb => '👍',
    Finger.indexFinger => '☝️',
    Finger.middle => '🖐',
    Finger.ring => '💍',
    Finger.pinky => '🤙',
  };
}

/// Indicador de score
class MatchScoreIndicator extends StatelessWidget {
  final double score;
  final bool isMatch;
  const MatchScoreIndicator({super.key, required this.score, required this.isMatch});

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    final color = isMatch ? Colors.green : (score > 0.5 ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isMatch ? Icons.check_circle : Icons.radio_button_unchecked, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
