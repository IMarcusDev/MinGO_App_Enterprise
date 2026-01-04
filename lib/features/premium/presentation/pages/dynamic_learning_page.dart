import 'package:flutter/material.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

class DynamicLearningPage extends StatefulWidget {
  const DynamicLearningPage({super.key});

  @override
  State<DynamicLearningPage> createState() => _DynamicLearningPageState();
}

class _DynamicLearningPageState extends State<DynamicLearningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprendizaje Dinámico')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space),
        children: [
          _buildStatsHeader(),
          const SizedBox(height: AppDimensions.spaceL),
          Text('Elige un juego', style: AppTypography.titleLarge),
          const SizedBox(height: AppDimensions.space),
          
          // Juego de Memoria
          _buildGameCard(
            context,
            icon: Icons.grid_view_rounded,
            title: 'Juego de Memoria',
            description: 'Encuentra los pares de señas y significados',
            color: AppColors.primary,
            difficulty: 'Fácil',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameScreen())),
          ),
          const SizedBox(height: AppDimensions.space),

          // Quiz
          _buildGameCard(
            context,
            icon: Icons.quiz,
            title: 'Quiz de Señas',
            description: 'Identifica la seña correcta',
            color: AppColors.secondary,
            difficulty: 'Medio',
            onTap: () => _showComingSoon(context, 'Quiz de Señas'),
          ),
          const SizedBox(height: AppDimensions.space),

          // Asociación visual
          _buildGameCard(
            context,
            icon: Icons.compare_arrows,
            title: 'Asociación Visual',
            description: 'Conecta señas con imágenes',
            color: AppColors.success,
            difficulty: 'Medio',
            onTap: () => _showComingSoon(context, 'Asociación Visual'),
          ),
          const SizedBox(height: AppDimensions.spaceXL),

          Text('Progreso semanal', style: AppTypography.titleLarge),
          const SizedBox(height: AppDimensions.space),
          _buildWeeklyProgress(),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.premium, AppColors.premium.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('🎮', '24', 'Juegos'),
              _buildStat('⭐', '156', 'Puntos'),
              _buildStat('🔥', '7', 'Racha'),
            ],
          ),
          const SizedBox(height: AppDimensions.space),
          AnimatedProgressBar(value: 0.72, height: 10, foregroundColor: Colors.white, backgroundColor: Colors.white24),
          const SizedBox(height: 8),
          Text('Nivel 5 - 72%', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value, style: AppTypography.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, {required IconData icon, required String title, required String description, required Color color, required String difficulty, required VoidCallback onTap}) {
    return AnimatedPressable(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: AppTypography.titleMedium)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (difficulty == 'Fácil' ? AppColors.success : difficulty == 'Medio' ? AppColors.warning : AppColors.error).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(difficulty, style: AppTypography.labelSmall.copyWith(color: difficulty == 'Fácil' ? AppColors.success : difficulty == 'Medio' ? AppColors.warning : AppColors.error)),
                        ),
                      ],
                    ),
                    Text(description, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final progress = [0.8, 1.0, 0.6, 0.9, 0.4, 0.0, 0.0];
    final today = DateTime.now().weekday - 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            return Column(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: progress[i] >= 0.8 ? AppColors.success : (progress[i] > 0 ? AppColors.warning.withOpacity(0.3) : AppColors.dividerLight),
                    shape: BoxShape.circle,
                    border: i == today ? Border.all(color: AppColors.primary, width: 2) : null,
                  ),
                  child: progress[i] >= 0.8 ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
                const SizedBox(height: 4),
                Text(days[i], style: AppTypography.bodySmall.copyWith(fontWeight: i == today ? FontWeight.bold : FontWeight.normal, color: i == today ? AppColors.primary : AppColors.textSecondary)),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature - Próximamente')));
  }
}

// ============================================
// Juego de Memoria (RF012.3)
// ============================================

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<_MemoryCard> _cards;
  int? _firstIndex;
  int? _secondIndex;
  int _matches = 0;
  int _attempts = 0;
  bool _canSelect = true;

  final _pairs = [
    {'sign': '👋', 'word': 'Hola'},
    {'sign': '🙏', 'word': 'Gracias'},
    {'sign': '❤️', 'word': 'Amor'},
    {'sign': '🏠', 'word': 'Casa'},
    {'sign': '👨‍👩‍👧', 'word': 'Familia'},
    {'sign': '💧', 'word': 'Agua'},
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _cards = [];
    for (var p in _pairs) {
      _cards.add(_MemoryCard(content: p['sign']!, pairId: p['word']!, isSign: true));
      _cards.add(_MemoryCard(content: p['word']!, pairId: p['word']!, isSign: false));
    }
    _cards.shuffle();
    _firstIndex = _secondIndex = null;
    _matches = _attempts = 0;
    _canSelect = true;
  }

  @override
  Widget build(BuildContext context) {
    final won = _matches == _pairs.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Memoria'),
        actions: [IconButton(onPressed: () => setState(_initGame), icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Text('$_matches/${_pairs.length}', style: AppTypography.headlineSmall), const Text('Pares')]),
                Column(children: [Text('$_attempts', style: AppTypography.headlineSmall), const Text('Intentos')]),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.space),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _cards.length,
              itemBuilder: (ctx, i) {
                final card = _cards[i];
                final selected = i == _firstIndex || i == _secondIndex;
                final matched = card.isMatched;

                return GestureDetector(
                  onTap: () => _onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: matched ? AppColors.success.withOpacity(0.2) : (selected ? AppColors.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: matched ? AppColors.success : (selected ? AppColors.primary : AppColors.dividerLight), width: selected || matched ? 2 : 1),
                    ),
                    child: Center(
                      child: selected || matched
                          ? (card.isSign ? Text(card.content, style: const TextStyle(fontSize: 32)) : Text(card.content, style: AppTypography.titleMedium, textAlign: TextAlign.center))
                          : const Icon(Icons.help_outline, size: 32, color: AppColors.textSecondary),
                    ),
                  ),
                );
              },
            ),
          ),
          if (won)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                  Text('¡Felicidades!', style: AppTypography.headlineSmall),
                  Text('Completado en $_attempts intentos'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => setState(_initGame), child: const Text('Jugar de nuevo')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _onTap(int i) {
    if (!_canSelect || _cards[i].isMatched || i == _firstIndex) return;
    setState(() {
      if (_firstIndex == null) {
        _firstIndex = i;
      } else {
        _secondIndex = i;
        _attempts++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    _canSelect = false;
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        if (_cards[_firstIndex!].pairId == _cards[_secondIndex!].pairId) {
          _cards[_firstIndex!].isMatched = _cards[_secondIndex!].isMatched = true;
          _matches++;
        }
        _firstIndex = _secondIndex = null;
        _canSelect = true;
      });
    });
  }
}

class _MemoryCard {
  final String content;
  final String pairId;
  final bool isSign;
  bool isMatched;
  _MemoryCard({required this.content, required this.pairId, required this.isSign, this.isMatched = false});
}
