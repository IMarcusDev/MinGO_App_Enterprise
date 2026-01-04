import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/content_import_entities.dart';

// ============================================
// Events
// ============================================

abstract class ContentImportEvent extends Equatable {
  const ContentImportEvent();

  @override
  List<Object?> get props => [];
}

class InitImportFormEvent extends ContentImportEvent {
  final String? classId;

  const InitImportFormEvent({this.classId});

  @override
  List<Object?> get props => [classId];
}

class UpdateTitleEvent extends ContentImportEvent {
  final String title;
  const UpdateTitleEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdatePhraseEvent extends ContentImportEvent {
  final String phrase;
  const UpdatePhraseEvent(this.phrase);

  @override
  List<Object?> get props => [phrase];
}

class UpdateCategoryEvent extends ContentImportEvent {
  final String category;
  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateLevelEvent extends ContentImportEvent {
  final String level;
  const UpdateLevelEvent(this.level);

  @override
  List<Object?> get props => [level];
}

class UpdateKeywordsEvent extends ContentImportEvent {
  final List<String> keywords;
  const UpdateKeywordsEvent(this.keywords);

  @override
  List<Object?> get props => [keywords];
}

class AddKeywordEvent extends ContentImportEvent {
  final String keyword;
  const AddKeywordEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class RemoveKeywordEvent extends ContentImportEvent {
  final String keyword;
  const RemoveKeywordEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class SelectVideoEvent extends ContentImportEvent {
  final String videoPath;
  const SelectVideoEvent(this.videoPath);

  @override
  List<Object?> get props => [videoPath];
}

class SelectImageEvent extends ContentImportEvent {
  final String imagePath;
  const SelectImageEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class RemoveVideoEvent extends ContentImportEvent {
  const RemoveVideoEvent();
}

class RemoveImageEvent extends ContentImportEvent {
  const RemoveImageEvent();
}

class SubmitContentEvent extends ContentImportEvent {
  const SubmitContentEvent();
}

class ResetFormEvent extends ContentImportEvent {
  const ResetFormEvent();
}

// ============================================
// State
// ============================================

enum ContentImportStatus {
  initial,
  editing,
  validating,
  uploading,
  success,
  error,
}

class ContentImportState extends Equatable {
  final ContentImportStatus status;
  final ContentImport content;
  final ImportProgress progress;
  final String? classId;
  final String? errorMessage;
  final Map<String, String?> fieldErrors;

  const ContentImportState({
    this.status = ContentImportStatus.initial,
    this.content = const ContentImport(
      title: '',
      phrase: '',
      category: '',
      level: '',
    ),
    this.progress = const ImportProgress(),
    this.classId,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  bool get isValid {
    return content.title.isNotEmpty &&
        content.phrase.isNotEmpty &&
        content.category.isNotEmpty &&
        content.level.isNotEmpty &&
        content.hasVideo;
  }

  bool get canSubmit => isValid && !progress.isUploading;

  bool get isCommonPhrases => content.level == 'Frases comunes';

  ContentImportState copyWith({
    ContentImportStatus? status,
    ContentImport? content,
    ImportProgress? progress,
    String? classId,
    String? errorMessage,
    Map<String, String?>? fieldErrors,
  }) {
    return ContentImportState(
      status: status ?? this.status,
      content: content ?? this.content,
      progress: progress ?? this.progress,
      classId: classId ?? this.classId,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
        status,
        content,
        progress,
        classId,
        errorMessage,
        fieldErrors,
      ];
}

// ============================================
// BLoC
// ============================================

class ContentImportBloc extends Bloc<ContentImportEvent, ContentImportState> {
  ContentImportBloc() : super(const ContentImportState()) {
    on<InitImportFormEvent>(_onInitForm);
    on<UpdateTitleEvent>(_onUpdateTitle);
    on<UpdatePhraseEvent>(_onUpdatePhrase);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<UpdateLevelEvent>(_onUpdateLevel);
    on<AddKeywordEvent>(_onAddKeyword);
    on<RemoveKeywordEvent>(_onRemoveKeyword);
    on<SelectVideoEvent>(_onSelectVideo);
    on<SelectImageEvent>(_onSelectImage);
    on<RemoveVideoEvent>(_onRemoveVideo);
    on<RemoveImageEvent>(_onRemoveImage);
    on<SubmitContentEvent>(_onSubmitContent);
    on<ResetFormEvent>(_onResetForm);
  }

  void _onInitForm(
    InitImportFormEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(ContentImportState(
      status: ContentImportStatus.editing,
      classId: event.classId,
    ));
  }

  void _onUpdateTitle(
    UpdateTitleEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(state.copyWith(
      content: state.content.copyWith(title: event.title),
      fieldErrors: {...state.fieldErrors, 'title': null},
    ));
  }

  void _onUpdatePhrase(
    UpdatePhraseEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(state.copyWith(
      content: state.content.copyWith(phrase: event.phrase),
      fieldErrors: {...state.fieldErrors, 'phrase': null},
    ));
  }

  void _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(state.copyWith(
      content: state.content.copyWith(category: event.category),
      fieldErrors: {...state.fieldErrors, 'category': null},
    ));
  }

  void _onUpdateLevel(
    UpdateLevelEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(state.copyWith(
      content: state.content.copyWith(level: event.level),
      fieldErrors: {...state.fieldErrors, 'level': null},
    ));
  }

  void _onAddKeyword(
    AddKeywordEvent event,
    Emitter<ContentImportState> emit,
  ) {
    if (event.keyword.trim().isEmpty) return;
    final keywords = List<String>.from(state.content.keywords);
    if (!keywords.contains(event.keyword.trim().toLowerCase())) {
      keywords.add(event.keyword.trim().toLowerCase());
      emit(state.copyWith(
        content: state.content.copyWith(keywords: keywords),
      ));
    }
  }

  void _onRemoveKeyword(
    RemoveKeywordEvent event,
    Emitter<ContentImportState> emit,
  ) {
    final keywords = List<String>.from(state.content.keywords);
    keywords.remove(event.keyword);
    emit(state.copyWith(
      content: state.content.copyWith(keywords: keywords),
    ));
  }

  void _onSelectVideo(
    SelectVideoEvent event,
    Emitter<ContentImportState> emit,
  ) {
    // Validar extensión
    final extension = event.videoPath.split('.').last.toLowerCase();
    if (extension != 'mp4') {
      emit(state.copyWith(
        fieldErrors: {...state.fieldErrors, 'video': 'Solo se permiten archivos MP4'},
      ));
      return;
    }

    emit(state.copyWith(
      content: state.content.copyWith(videoPath: event.videoPath),
      progress: state.progress.copyWith(videoStatus: UploadStatus.success),
      fieldErrors: {...state.fieldErrors, 'video': null},
    ));
  }

  void _onSelectImage(
    SelectImageEvent event,
    Emitter<ContentImportState> emit,
  ) {
    // Validar extensión
    final extension = event.imagePath.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(extension)) {
      emit(state.copyWith(
        fieldErrors: {...state.fieldErrors, 'image': 'Solo se permiten archivos JPG o PNG'},
      ));
      return;
    }

    emit(state.copyWith(
      content: state.content.copyWith(imagePath: event.imagePath),
      progress: state.progress.copyWith(imageStatus: UploadStatus.success),
      fieldErrors: {...state.fieldErrors, 'image': null},
    ));
  }

  void _onRemoveVideo(
    RemoveVideoEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(state.copyWith(
      content: state.content.copyWith(videoPath: null, videoUrl: null),
      progress: state.progress.copyWith(videoStatus: UploadStatus.idle),
    ));
  }

  void _onRemoveImage(
    RemoveImageEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(state.copyWith(
      content: state.content.copyWith(imagePath: null, imageUrl: null),
      progress: state.progress.copyWith(imageStatus: UploadStatus.idle),
    ));
  }

  Future<void> _onSubmitContent(
    SubmitContentEvent event,
    Emitter<ContentImportState> emit,
  ) async {
    // Validar campos
    final errors = _validateFields();
    if (errors.isNotEmpty) {
      emit(state.copyWith(
        status: ContentImportStatus.error,
        fieldErrors: errors,
        errorMessage: 'Por favor complete todos los campos requeridos',
      ));
      return;
    }

    emit(state.copyWith(status: ContentImportStatus.uploading));

    try {
      // Simular subida (en producción, aquí se subiría al servidor)
      await Future.delayed(const Duration(seconds: 2));

      // Actualizar progreso de video
      emit(state.copyWith(
        progress: state.progress.copyWith(
          videoStatus: UploadStatus.uploading,
          videoProgress: 0.5,
        ),
      ));
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(
        progress: state.progress.copyWith(
          videoStatus: UploadStatus.success,
          videoProgress: 1.0,
        ),
      ));

      // Actualizar progreso de imagen si existe
      if (state.content.hasImage) {
        emit(state.copyWith(
          progress: state.progress.copyWith(
            imageStatus: UploadStatus.uploading,
            imageProgress: 0.5,
          ),
        ));
        await Future.delayed(const Duration(milliseconds: 300));

        emit(state.copyWith(
          progress: state.progress.copyWith(
            imageStatus: UploadStatus.success,
            imageProgress: 1.0,
          ),
        ));
      }

      // Éxito
      emit(state.copyWith(
        status: ContentImportStatus.success,
        content: state.content.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ContentImportStatus.error,
        errorMessage: 'Error al importar contenido: $e',
      ));
    }
  }

  void _onResetForm(
    ResetFormEvent event,
    Emitter<ContentImportState> emit,
  ) {
    emit(ContentImportState(
      status: ContentImportStatus.editing,
      classId: state.classId,
    ));
  }

  Map<String, String?> _validateFields() {
    final errors = <String, String?>{};

    if (state.content.title.isEmpty) {
      errors['title'] = 'El título es requerido';
    }
    if (state.content.phrase.isEmpty) {
      errors['phrase'] = state.isCommonPhrases
          ? 'La frase es requerida'
          : 'La oración de ejemplo es requerida';
    }
    if (state.content.category.isEmpty) {
      errors['category'] = 'La categoría es requerida';
    }
    if (state.content.level.isEmpty) {
      errors['level'] = 'El nivel es requerido';
    }
    if (!state.content.hasVideo) {
      errors['video'] = 'El video es requerido';
    }

    return errors;
  }
}
