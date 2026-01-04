import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/translator_entities.dart';
import '../bloc/translator_bloc.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<TranslatorBloc>().add(const LoadHistoryEvent());
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor de Señas'),
        actions: [
          IconButton(
            onPressed: () => _showHistorySheet(context),
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
          ),
        ],
      ),
      body: BlocBuilder<TranslatorBloc, TranslatorState>(
        builder: (context, state) {
          return Column(
            children: [
              // Input de texto
              _buildInputSection(context, state),

              // Resultado
              Expanded(
                child: _buildResultSection(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, TranslatorState state) {
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
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Escribe una palabra o frase...',
              prefixIcon: const Icon(Icons.translate),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_textController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _textController.clear();
                        context.read<TranslatorBloc>().add(const ClearTranslationEvent());
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  IconButton(
                    onPressed: state.status == TranslatorStatus.loading
                        ? null
                        : () => _translate(context),
                    icon: state.status == TranslatorStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _translate(context),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimensions.spaceS),

          // Sugerencias rápidas
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSuggestionChip('Hola'),
                _buildSuggestionChip('Gracias'),
                _buildSuggestionChip('¿Cómo estás?'),
                _buildSuggestionChip('Buenos días'),
                _buildSuggestionChip('Adiós'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text),
        onPressed: () {
          _textController.text = text;
          _translate(context);
        },
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, TranslatorState state) {
    if (state.status == TranslatorStatus.initial) {
      return _buildEmptyState();
    }

    if (state.status == TranslatorStatus.loading) {
      return const Center(
        child: LoadingAnimation(
          size: 100,
          message: 'Traduciendo...',
        ),
      );
    }

    if (state.status == TranslatorStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'Error desconocido'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _translate(context),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final result = state.result;
    if (result == null) return _buildEmptyState();

    if (result.isSpelling) {
      return _buildDactylologyResult(context, result);
    } else {
      return _buildDirectTranslationResult(context, result);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sign_language,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Escribe una palabra o frase',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Te mostraremos la seña correspondiente\no el deletreo letra por letra',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectTranslationResult(
    BuildContext context,
    TranslationResult result,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space),
      children: [
        // Texto traducido
        Container(
          padding: const EdgeInsets.all(AppDimensions.space),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Traducción encontrada!',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      '"${result.inputText}"',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),

        // Señas traducidas
        ...result.translations.asMap().entries.map((entry) {
          return AnimatedFadeIn(
            delay: Duration(milliseconds: 200 * entry.key),
            child: _buildSignCard(entry.value),
          );
        }),
      ],
    );
  }

  Widget _buildSignCard(SignTranslation sign) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sign.category,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(sign.word, style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: AppDimensions.space),

            // Imagen/Video placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sign_language,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seña: ${sign.word}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (sign.hasVideo) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Reproducir video
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Ver video'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (sign.description != null) ...[
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                sign.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDactylologyResult(
    BuildContext context,
    TranslationResult result,
  ) {
    final letters = result.dactylology ?? [];

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space),
      children: [
        // Aviso de deletreo
        Container(
          padding: const EdgeInsets.all(AppDimensions.space),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Palabra no encontrada',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mostrando deletreo en dactilología (alfabeto manual)',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space),

        // Palabra deletreada
        Center(
          child: Text(
            '"${result.inputText}"',
            style: AppTypography.headlineMedium.copyWith(
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),

        // Grid de letras
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: letters.length,
          itemBuilder: (context, index) {
            return AnimatedBounceIn(
              delay: Duration(milliseconds: 100 * index),
              child: _buildLetterCard(letters[index], index),
            );
          },
        ),
        const SizedBox(height: AppDimensions.spaceL),

        // Información adicional
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text('¿Sabías que...?', style: AppTypography.titleSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'La dactilología es el alfabeto manual utilizado en la Lengua de Señas Ecuatoriana (LSEC) para deletrear nombres propios, palabras técnicas o términos que no tienen una seña específica.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterCard(DactylologyLetter letter, int index) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.sign_language,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            letter.letter,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${index + 1}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _translate(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _focusNode.unfocus();
      context.read<TranslatorBloc>().add(TranslateTextEvent(text));
    }
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<TranslatorBloc, TranslatorState>(
        builder: (context, state) {
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder: (_, controller) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.space),
                    child: Row(
                      children: [
                        Text('Historial', style: AppTypography.titleLarge),
                        const Spacer(),
                        if (state.history.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              context.read<TranslatorBloc>().add(const ClearHistoryEvent());
                            },
                            child: const Text('Limpiar'),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: state.history.isEmpty
                        ? const Center(
                            child: Text('Sin historial de traducciones'),
                          )
                        : ListView.builder(
                            controller: controller,
                            itemCount: state.history.length,
                            itemBuilder: (context, index) {
                              final item = state.history[index];
                              return ListTile(
                                leading: Icon(
                                  item.type == TranslationType.direct
                                      ? Icons.check_circle
                                      : Icons.text_fields,
                                  color: item.type == TranslationType.direct
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                title: Text(item.text),
                                subtitle: Text(
                                  _formatDate(item.timestamp),
                                  style: AppTypography.bodySmall,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.pop(context);
                                  _textController.text = item.text;
                                  context.read<TranslatorBloc>().add(
                                        SelectHistoryItemEvent(item),
                                      );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}
