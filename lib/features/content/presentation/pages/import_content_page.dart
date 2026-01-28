import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/content_import_entities.dart';
import '../bloc/content_import_bloc.dart';

class ImportContentPage extends StatefulWidget {
  final String? classId;

  const ImportContentPage({super.key, this.classId});

  @override
  State<ImportContentPage> createState() => _ImportContentPageState();
}

class _ImportContentPageState extends State<ImportContentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _phraseController = TextEditingController();
  final _exampleSentenceController = TextEditingController();
  final _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ContentImportBloc>().add(InitImportFormEvent(classId: widget.classId));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
    _audioUrlController.dispose();
    _phraseController.dispose();
    _exampleSentenceController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Contenido'),
        actions: [
          BlocBuilder<ContentImportBloc, ContentImportState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state.status == ContentImportStatus.submitting
                    ? null
                    : () => _resetForm(context),
                icon: const Icon(Icons.refresh),
                tooltip: 'Limpiar formulario',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ContentImportBloc, ContentImportState>(
        listener: (context, state) {
          if (state.status == ContentImportStatus.success) {
            _showSuccessDialog(context);
          }
          if (state.status == ContentImportStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppDimensions.space),
                  children: [
                    // Tipo de contenido
                    _buildSectionHeader('Tipo de Contenido', Icons.category),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildContentTypeSelector(context, state),
                    const SizedBox(height: AppDimensions.spaceL),

                    // URLs de multimedia
                    _buildSectionHeader('URLs de Multimedia', Icons.link),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildUrlField(
                      controller: _videoUrlController,
                      label: 'URL del Video *',
                      hint: 'https://ejemplo.com/video.mp4',
                      icon: Icons.videocam,
                      error: state.fieldErrors['videoUrl'],
                      onChanged: (v) => context.read<ContentImportBloc>().add(UpdateVideoUrlEvent(v)),
                    ),
                    const SizedBox(height: AppDimensions.space),
                    _buildUrlField(
                      controller: _imageUrlController,
                      label: 'URL de Imagen (opcional)',
                      hint: 'https://ejemplo.com/imagen.jpg',
                      icon: Icons.image,
                      error: state.fieldErrors['imageUrl'],
                      onChanged: (v) => context.read<ContentImportBloc>().add(UpdateImageUrlEvent(v)),
                    ),
                    const SizedBox(height: AppDimensions.space),
                    _buildUrlField(
                      controller: _audioUrlController,
                      label: 'URL de Audio (opcional)',
                      hint: 'https://ejemplo.com/audio.mp3',
                      icon: Icons.audiotrack,
                      error: state.fieldErrors['audioUrl'],
                      onChanged: (v) => context.read<ContentImportBloc>().add(UpdateAudioUrlEvent(v)),
                    ),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Información del contenido
                    _buildSectionHeader('Información del Contenido', Icons.info_outline),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Título del contenido *',
                      hint: 'Ej: Saludo formal',
                      icon: Icons.title,
                      error: state.fieldErrors['title'],
                      onChanged: (v) => context.read<ContentImportBloc>().add(UpdateTitleEvent(v)),
                    ),
                    const SizedBox(height: AppDimensions.space),

                    // Campos según tipo de contenido
                    ..._buildTypeSpecificFields(context, state),

                    const SizedBox(height: AppDimensions.space),
                    _buildTextField(
                      controller: _exampleSentenceController,
                      label: 'Oración de ejemplo (opcional)',
                      hint: 'Ej: Uso esta seña para saludar formalmente',
                      icon: Icons.format_quote,
                      maxLines: 2,
                      onChanged: (v) => context.read<ContentImportBloc>().add(UpdateExampleSentenceEvent(v)),
                    ),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Categoría de edad
                    _buildSectionHeader('Público Objetivo', Icons.people),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildAgeCategoryDropdown(context, state),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Palabras clave
                    _buildSectionHeader('Palabras Clave (Opcional)', Icons.tag),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildKeywordsInput(context, state),
                    const SizedBox(height: AppDimensions.spaceXL),

                    // Botón de envío
                    _buildSubmitButton(context, state),
                    const SizedBox(height: AppDimensions.space),
                    _buildFormatInfo(),
                    const SizedBox(height: AppDimensions.spaceXL),
                  ],
                ),
              ),
              if (state.status == ContentImportStatus.submitting) _buildSubmittingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildContentTypeSelector(BuildContext context, ContentImportState state) {
    return Column(
      children: SignContentType.values.map((type) {
        final isSelected = state.content.contentType == type;
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: RadioListTile<SignContentType>(
            value: type,
            groupValue: state.content.contentType,
            onChanged: (value) {
              if (value != null) {
                context.read<ContentImportBloc>().add(UpdateContentTypeEvent(value));
              }
            },
            title: Text(
              type.displayName,
              style: AppTypography.titleSmall.copyWith(
                color: isSelected ? AppColors.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
            subtitle: Text(
              _getContentTypeDescription(type),
              style: AppTypography.bodySmall,
            ),
            activeColor: AppColors.primary,
          ),
        );
      }).toList(),
    );
  }

  String _getContentTypeDescription(SignContentType type) {
    switch (type) {
      case SignContentType.dictionary:
        return 'Señas individuales para el diccionario de principiantes';
      case SignContentType.lesson:
        return 'Contenido para lecciones de nivel intermedio/avanzado';
      case SignContentType.commonPhrase:
        return 'Frases completas de uso cotidiano';
    }
  }

  List<Widget> _buildTypeSpecificFields(BuildContext context, ContentImportState state) {
    switch (state.content.contentType) {
      case SignContentType.dictionary:
        return [
          _buildLevelSectionDropdown(context, state),
          const SizedBox(height: AppDimensions.space),
          _buildContentCategoryDropdown(context, state),
        ];

      case SignContentType.commonPhrase:
        return [
          _buildCommonPhraseCategoryDropdown(context, state),
          const SizedBox(height: AppDimensions.space),
          _buildTextField(
            controller: _phraseController,
            label: 'Frase completa *',
            hint: 'Ej: ¿Cómo te sientes hoy?',
            icon: Icons.chat_bubble_outline,
            maxLines: 2,
            error: state.fieldErrors['phrase'],
            onChanged: (v) => context.read<ContentImportBloc>().add(UpdatePhraseEvent(v)),
          ),
        ];

      case SignContentType.lesson:
        return [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: AppDimensions.space),
                Expanded(
                  child: Text(
                    'Las lecciones se asocian automáticamente a través del sistema de módulos y actividades.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ];
    }
  }

  Widget _buildUrlField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? error,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            errorText: error,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? error,
    int maxLines = 1,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        errorText: error,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildLevelSectionDropdown(BuildContext context, ContentImportState state) {
    return DropdownButtonFormField<String>(
      value: state.content.levelSectionId,
      decoration: InputDecoration(
        labelText: 'Nivel / Sección *',
        prefixIcon: const Icon(Icons.signal_cellular_alt),
        errorText: state.fieldErrors['levelSection'],
      ),
      items: ContentCategories.levelSections.map((level) {
        return DropdownMenuItem(
          value: level['id'],
          child: Text(level['name']!),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<ContentImportBloc>().add(UpdateLevelSectionEvent(value));
        }
      },
    );
  }

  Widget _buildContentCategoryDropdown(BuildContext context, ContentImportState state) {
    return DropdownButtonFormField<String>(
      value: state.content.contentCategoryId,
      decoration: InputDecoration(
        labelText: 'Categoría de la seña *',
        prefixIcon: const Icon(Icons.category),
        errorText: state.fieldErrors['contentCategory'],
      ),
      items: ContentCategories.signCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<ContentImportBloc>().add(UpdateContentCategoryEvent(value));
        }
      },
    );
  }

  Widget _buildCommonPhraseCategoryDropdown(BuildContext context, ContentImportState state) {
    return DropdownButtonFormField<String>(
      value: state.content.commonPhraseCategoryId,
      decoration: InputDecoration(
        labelText: 'Categoría de frase *',
        prefixIcon: const Icon(Icons.chat),
        errorText: state.fieldErrors['commonPhraseCategory'],
      ),
      items: ContentCategories.commonPhraseCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<ContentImportBloc>().add(UpdateCommonPhraseCategoryEvent(value));
        }
      },
    );
  }

  Widget _buildAgeCategoryDropdown(BuildContext context, ContentImportState state) {
    return DropdownButtonFormField<String>(
      value: state.content.ageCategoryId,
      decoration: const InputDecoration(
        labelText: 'Rango de edad (opcional)',
        prefixIcon: Icon(Icons.people_outline),
      ),
      items: ContentCategories.ageCategories.map((age) {
        return DropdownMenuItem(
          value: age['id'] as String,
          child: Text(age['name'] as String),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<ContentImportBloc>().add(UpdateAgeCategoryEvent(value));
        }
      },
    );
  }

  Widget _buildKeywordsInput(BuildContext context, ContentImportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _keywordController,
                decoration: const InputDecoration(
                  hintText: 'Agregar palabra clave',
                  prefixIcon: Icon(Icons.add),
                ),
                onSubmitted: (_) => _addKeyword(context),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _addKeyword(context),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (state.content.keywords.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spaceS),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.content.keywords.map((keyword) {
              return Chip(
                label: Text(keyword),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => context.read<ContentImportBloc>().add(RemoveKeywordEvent(keyword)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ContentImportState state) {
    return ElevatedButton.icon(
      onPressed: state.canSubmit
          ? () => context.read<ContentImportBloc>().add(const SubmitContentEvent())
          : null,
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Guardar Contenido'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space),
      ),
    );
  }

  Widget _buildFormatInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Formatos recomendados',
                style: AppTypography.titleSmall.copyWith(color: AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('• Video: MP4, WebM (YouTube, Vimeo, etc.)', style: AppTypography.bodySmall),
          Text('• Imagen: JPG, PNG, WebP', style: AppTypography.bodySmall),
          Text('• Audio: MP3, WAV, OGG', style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(
            '• Asegúrate de que las URLs sean públicamente accesibles',
            style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppDimensions.space),
                Text('Guardando contenido...', style: AppTypography.titleMedium),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  'Por favor espere mientras se procesa el contenido',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addKeyword(BuildContext context) {
    final keyword = _keywordController.text.trim();
    if (keyword.isNotEmpty) {
      context.read<ContentImportBloc>().add(AddKeywordEvent(keyword));
      _keywordController.clear();
    }
  }

  void _resetForm(BuildContext context) {
    context.read<ContentImportBloc>().add(const ResetFormEvent());
    _titleController.clear();
    _videoUrlController.clear();
    _imageUrlController.clear();
    _audioUrlController.clear();
    _phraseController.clear();
    _exampleSentenceController.clear();
    _keywordController.clear();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        title: const Text('¡Contenido Guardado!'),
        content: const Text(
          'El contenido se ha guardado correctamente y estará disponible para los estudiantes.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm(context);
            },
            child: const Text('Agregar otro'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
