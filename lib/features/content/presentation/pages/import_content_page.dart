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
  final _titleController = TextEditingController();
  final _phraseController = TextEditingController();
  final _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ContentImportBloc>().add(InitImportFormEvent(classId: widget.classId));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _phraseController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Contenido'),
        actions: [
          BlocBuilder<ContentImportBloc, ContentImportState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state.status == ContentImportStatus.uploading
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
          if (state.status == ContentImportStatus.error &&
              state.errorMessage != null) {
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
              ListView(
                padding: const EdgeInsets.all(AppDimensions.space),
                children: [
                  _buildSectionHeader('Archivos Multimedia', Icons.video_library),
                  const SizedBox(height: AppDimensions.spaceS),
                  _buildVideoSelector(context, state),
                  const SizedBox(height: AppDimensions.space),
                  _buildImageSelector(context, state),
                  const SizedBox(height: AppDimensions.spaceL),

                  _buildSectionHeader('Información del Contenido', Icons.info_outline),
                  const SizedBox(height: AppDimensions.spaceS),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Título del contenido',
                    hint: 'Ej: Saludo formal',
                    icon: Icons.title,
                    error: state.fieldErrors['title'],
                    onChanged: (v) => context.read<ContentImportBloc>().add(UpdateTitleEvent(v)),
                  ),
                  const SizedBox(height: AppDimensions.space),
                  _buildLevelDropdown(context, state),
                  const SizedBox(height: AppDimensions.space),
                  _buildCategoryDropdown(context, state),
                  const SizedBox(height: AppDimensions.space),
                  _buildTextField(
                    controller: _phraseController,
                    label: state.isCommonPhrases ? 'Frase exacta' : 'Oración de ejemplo',
                    hint: state.isCommonPhrases ? 'Ej: ¿Cómo te sientes?' : 'Ej: Uso esta seña para saludar',
                    icon: Icons.format_quote,
                    maxLines: 2,
                    error: state.fieldErrors['phrase'],
                    onChanged: (v) => context.read<ContentImportBloc>().add(UpdatePhraseEvent(v)),
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  _buildSectionHeader('Palabras Clave (Opcional)', Icons.tag),
                  const SizedBox(height: AppDimensions.spaceS),
                  _buildKeywordsInput(context, state),
                  const SizedBox(height: AppDimensions.spaceXL),

                  _buildSubmitButton(context, state),
                  const SizedBox(height: AppDimensions.space),
                  _buildFormatInfo(),
                  const SizedBox(height: AppDimensions.spaceXL),
                ],
              ),
              if (state.status == ContentImportStatus.uploading)
                _buildUploadingOverlay(state),
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

  Widget _buildVideoSelector(BuildContext context, ContentImportState state) {
    final hasVideo = state.content.hasVideo;
    final error = state.fieldErrors['video'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _pickVideo(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: hasVideo
                  ? AppColors.success.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: error != null ? AppColors.error : (hasVideo ? AppColors.success : Colors.transparent),
                width: error != null ? 2 : 1,
              ),
            ),
            child: hasVideo
                ? _buildSelectedFile(
                    state.content.videoPath!,
                    Icons.videocam,
                    AppColors.success,
                    onRemove: () => context.read<ContentImportBloc>().add(const RemoveVideoEvent()),
                  )
                : _buildFilePlaceholder('Subir Video', 'MP4 (máx. 50MB)', Icons.video_call),
          ),
        ),
        if (error != null) _buildErrorText(error),
        _buildHelperText('* Requerido'),
      ],
    );
  }

  Widget _buildImageSelector(BuildContext context, ContentImportState state) {
    final hasImage = state.content.hasImage;
    final error = state.fieldErrors['image'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _pickImage(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: hasImage
                  ? AppColors.info.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: error != null ? AppColors.error : (hasImage ? AppColors.info : Colors.transparent),
              ),
            ),
            child: hasImage
                ? _buildSelectedFile(
                    state.content.imagePath!,
                    Icons.image,
                    AppColors.info,
                    onRemove: () => context.read<ContentImportBloc>().add(const RemoveImageEvent()),
                  )
                : _buildFilePlaceholder('Subir Imagen', 'JPG, PNG (máx. 50MB)', Icons.add_photo_alternate),
          ),
        ),
        if (error != null) _buildErrorText(error),
        _buildHelperText('Opcional'),
      ],
    );
  }

  Widget _buildFilePlaceholder(String title, String subtitle, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Text(title, style: AppTypography.titleSmall),
        Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSelectedFile(String path, IconData icon, Color color, {VoidCallback? onRemove}) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(path.split('/').last, style: AppTypography.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text('Archivo seleccionado', style: AppTypography.bodySmall.copyWith(color: color)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close), color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12),
      child: Text(error, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
    );
  }

  Widget _buildHelperText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
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
      decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), errorText: error),
      onChanged: onChanged,
    );
  }

  Widget _buildLevelDropdown(BuildContext context, ContentImportState state) {
    return DropdownButtonFormField<String>(
      value: state.content.level.isEmpty ? null : state.content.level,
      decoration: InputDecoration(
        labelText: 'Nivel / Sección',
        prefixIcon: const Icon(Icons.signal_cellular_alt),
        errorText: state.fieldErrors['level'],
      ),
      items: ContentCategories.levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
      onChanged: (v) {
        if (v != null) context.read<ContentImportBloc>().add(UpdateLevelEvent(v));
      },
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, ContentImportState state) {
    final categories = state.isCommonPhrases ? ContentCategories.commonPhraseCategories : ContentCategories.signCategories;
    return DropdownButtonFormField<String>(
      value: state.content.category.isEmpty ? null : state.content.category,
      decoration: InputDecoration(
        labelText: 'Categoría de la seña',
        prefixIcon: const Icon(Icons.category),
        errorText: state.fieldErrors['category'],
      ),
      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) {
        if (v != null) context.read<ContentImportBloc>().add(UpdateCategoryEvent(v));
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
                decoration: const InputDecoration(hintText: 'Agregar palabra clave', prefixIcon: Icon(Icons.add)),
                onSubmitted: (_) => _addKeyword(context),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: () => _addKeyword(context), icon: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.content.keywords.map((k) {
            return Chip(
              label: Text(k),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => context.read<ContentImportBloc>().add(RemoveKeywordEvent(k)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ContentImportState state) {
    return ElevatedButton.icon(
      onPressed: state.canSubmit ? () => context.read<ContentImportBloc>().add(const SubmitContentEvent()) : null,
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Importar Contenido'),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppDimensions.space)),
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
              Text('Formatos permitidos', style: AppTypography.titleSmall.copyWith(color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 8),
          Text('• Video: MP4', style: AppTypography.bodySmall),
          Text('• Imagen: JPG, PNG', style: AppTypography.bodySmall),
          Text('• Tamaño máximo: 50 MB', style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildUploadingOverlay(ContentImportState state) {
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
                Text('Importando contenido...', style: AppTypography.titleMedium),
                const SizedBox(height: AppDimensions.space),
                if (state.progress.videoProgress > 0)
                  Column(
                    children: [
                      Text('Video: ${(state.progress.videoProgress * 100).toInt()}%'),
                      LinearProgressIndicator(value: state.progress.videoProgress),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickVideo(BuildContext context) {
    // Simulación - en producción usar file_picker
    context.read<ContentImportBloc>().add(const SelectVideoEvent('/storage/DCIM/video_seña.mp4'));
  }

  void _pickImage(BuildContext context) {
    context.read<ContentImportBloc>().add(const SelectImageEvent('/storage/DCIM/imagen_seña.jpg'));
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
    _phraseController.clear();
    _keywordController.clear();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        title: const Text('¡Contenido Importado!'),
        content: const Text('El contenido se ha importado correctamente y estará disponible para los padres.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm(context);
            },
            child: const Text('Importar otro'),
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
