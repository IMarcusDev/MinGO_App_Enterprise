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

class UpdateVideoUrlEvent extends ContentImportEvent {
  final String videoUrl;
  const UpdateVideoUrlEvent(this.videoUrl);

  @override
  List<Object?> get props => [videoUrl];
}

class UpdateImageUrlEvent extends ContentImportEvent {
  final String imageUrl;
  const UpdateImageUrlEvent(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class UpdateAudioUrlEvent extends ContentImportEvent {
  final String audioUrl;
  const UpdateAudioUrlEvent(this.audioUrl);

  @override
  List<Object?> get props => [audioUrl];
}

class UpdatePhraseEvent extends ContentImportEvent {
  final String phrase;
  const UpdatePhraseEvent(this.phrase);

  @override
  List<Object?> get props => [phrase];
}

class UpdateExampleSentenceEvent extends ContentImportEvent {
  final String exampleSentence;
  const UpdateExampleSentenceEvent(this.exampleSentence);

  @override
  List<Object?> get props => [exampleSentence];
}

class UpdateContentTypeEvent extends ContentImportEvent {
  final SignContentType contentType;
  const UpdateContentTypeEvent(this.contentType);

  @override
  List<Object?> get props => [contentType];
}

class UpdateLevelSectionEvent extends ContentImportEvent {
  final String levelSectionId;
  const UpdateLevelSectionEvent(this.levelSectionId);

  @override
  List<Object?> get props => [levelSectionId];
}

class UpdateContentCategoryEvent extends ContentImportEvent {
  final String contentCategoryId;
  const UpdateContentCategoryEvent(this.contentCategoryId);

  @override
  List<Object?> get props => [contentCategoryId];
}

class UpdateCommonPhraseCategoryEvent extends ContentImportEvent {
  final String commonPhraseCategoryId;
  const UpdateCommonPhraseCategoryEvent(this.commonPhraseCategoryId);

  @override
  List<Object?> get props => [commonPhraseCategoryId];
}

class UpdateAgeCategoryEvent extends ContentImportEvent {
  final String ageCategoryId;
  const UpdateAgeCategoryEvent(this.ageCategoryId);

  @override
  List<Object?> get props => [ageCategoryId];
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

class SubmitContentEvent extends ContentImportEvent {
  const SubmitContentEvent();
}

class ResetFormEvent extends ContentImportEvent {
  const ResetFormEvent();
}

// ============================================
// State
// ============================================

class ContentImportState extends Equatable {
  final ContentImportStatus status;
  final ContentImport content;
  final String? classId;
  final String? errorMessage;
  final Map<String, String?> fieldErrors;

  const ContentImportState({
    this.status = ContentImportStatus.initial,
    this.content = const ContentImport(title: ''),
    this.classId,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  bool get isValid => content.isValid;

  bool get canSubmit => isValid && status != ContentImportStatus.submitting;

  bool get isCommonPhrases => content.contentType == SignContentType.commonPhrase;

  bool get isDictionary => content.contentType == SignContentType.dictionary;

  bool get isLesson => content.contentType == SignContentType.lesson;

  ContentImportState copyWith({
    ContentImportStatus? status,
    ContentImport? content,
    String? classId,
    String? errorMessage,
    Map<String, String?>? fieldErrors,
  }) {
    return ContentImportState(
      status: status ?? this.status,
      content: content ?? this.content,
      classId: classId ?? this.classId,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [status, content, classId, errorMessage, fieldErrors];
}

// ============================================
// BLoC
// ============================================

class ContentImportBloc extends Bloc<ContentImportEvent, ContentImportState> {
  ContentImportBloc() : super(const ContentImportState()) {
    on<InitImportFormEvent>(_onInitForm);
    on<UpdateTitleEvent>(_onUpdateTitle);
    on<UpdateVideoUrlEvent>(_onUpdateVideoUrl);
    on<UpdateImageUrlEvent>(_onUpdateImageUrl);
    on<UpdateAudioUrlEvent>(_onUpdateAudioUrl);
    on<UpdatePhraseEvent>(_onUpdatePhrase);
    on<UpdateExampleSentenceEvent>(_onUpdateExampleSentence);
    on<UpdateContentTypeEvent>(_onUpdateContentType);
    on<UpdateLevelSectionEvent>(_onUpdateLevelSection);
    on<UpdateContentCategoryEvent>(_onUpdateContentCategory);
    on<UpdateCommonPhraseCategoryEvent>(_onUpdateCommonPhraseCategory);
    on<UpdateAgeCategoryEvent>(_onUpdateAgeCategory);
    on<AddKeywordEvent>(_onAddKeyword);
    on<RemoveKeywordEvent>(_onRemoveKeyword);
    on<SubmitContentEvent>(_onSubmitContent);
    on<ResetFormEvent>(_onResetForm);
  }

  void _onInitForm(InitImportFormEvent event, Emitter<ContentImportState> emit) {
    emit(ContentImportState(
      status: ContentImportStatus.editing,
      classId: event.classId,
      content: ContentImport(
        title: '',
        classId: event.classId,
      ),
    ));
  }

  void _onUpdateTitle(UpdateTitleEvent event, Emitter<ContentImportState> emit) {
    emit(state.copyWith(
      content: state.content.copyWith(title: event.title),
      fieldErrors: {...state.fieldErrors, 'title': null},
    ));
  }

  void _onUpdateVideoUrl(UpdateVideoUrlEvent event, Emitter<ContentImportState> emit) {
    final url = event.videoUrl.trim();
    String? error;

    if (url.isNotEmpty && !_isValidUrl(url)) {
      error = 'URL de video no válida';
    }

    emit(state.copyWith(
      content: state.content.copyWith(videoUrl: url.isEmpty ? null : url),
      fieldErrors: {...state.fieldErrors, 'videoUrl': error},
    ));
  }

  void _onUpdateImageUrl(UpdateImageUrlEvent event, Emitter<ContentImportState> emit) {
    final url = event.imageUrl.trim();
    String? error;

    if (url.isNotEmpty && !_isValidUrl(url)) {
      error = 'URL de imagen no válida';
    }

    emit(state.copyWith(
      content: state.content.copyWith(imageUrl: url.isEmpty ? null : url),
      fieldErrors: {...state.fieldErrors, 'imageUrl': error},
    ));
  }

  void _onUpdateAudioUrl(UpdateAudioUrlEvent event, Emitter<ContentImportState> emit) {
    final url = event.audioUrl.trim();
    String? error;

    if (url.isNotEmpty && !_isValidUrl(url)) {
      error = 'URL de audio no válida';
    }

    emit(state.copyWith(
      content: state.content.copyWith(audioUrl: url.isEmpty ? null : url),
      fieldErrors: {...state.fieldErrors, 'audioUrl': error},
    ));
  }

  void _onUpdatePhrase(UpdatePhraseEvent event, Emitter<ContentImportState> emit) {
    emit(state.copyWith(
      content: state.content.copyWith(phrase: event.phrase),
      fieldErrors: {...state.fieldErrors, 'phrase': null},
    ));
  }

  void _onUpdateExampleSentence(UpdateExampleSentenceEvent event, Emitter<ContentImportState> emit) {
    emit(state.copyWith(
      content: state.content.copyWith(exampleSentence: event.exampleSentence),
    ));
  }

  void _onUpdateContentType(UpdateContentTypeEvent event, Emitter<ContentImportState> emit) {
    // Limpiar campos específicos del tipo anterior
    final newContent = state.content.clearForContentType(event.contentType);
    emit(state.copyWith(
      content: newContent,
      fieldErrors: {}, // Limpiar errores al cambiar tipo
    ));
  }

  void _onUpdateLevelSection(UpdateLevelSectionEvent event, Emitter<ContentImportState> emit) {
    emit(state.copyWith(
      content: state.content.copyWith(levelSectionId: event.levelSectionId),
      fieldErrors: {...state.fieldErrors, 'levelSection': null},
    ));
  }

  void _onUpdateContentCategory(UpdateContentCategoryEvent event, Emitter<ContentImportState> emit) {
    emit(state.copyWith(
      content: state.content.copyWith(contentCategoryId: event.contentCategoryId),
      fieldErrors: {...state.fieldErrors, 'contentCategory': null},
    ));
  }

  void _onUpdateCommonPhraseCategory(UpdateCommonPhraseCategoryEvent event, Emitter<ContentImportState> emit) {
    emit(state.copyWith(
      content: state.content.copyWith(commonPhraseCategoryId: event.commonPhraseCategoryId),
      fieldErrors: {...state.fieldErrors, 'commonPhraseCategory': null},
    ));
  }

  void _onUpdateAgeCategory(UpdateAgeCategoryEvent event, Emitter<ContentImportState> emit) {
    emit(state.copyWith(
      content: state.content.copyWith(ageCategoryId: event.ageCategoryId),
    ));
  }

  void _onAddKeyword(AddKeywordEvent event, Emitter<ContentImportState> emit) {
    final keyword = event.keyword.trim().toLowerCase();
    if (keyword.isEmpty) return;

    final keywords = List<String>.from(state.content.keywords);
    if (!keywords.contains(keyword)) {
      keywords.add(keyword);
      emit(state.copyWith(
        content: state.content.copyWith(keywords: keywords),
      ));
    }
  }

  void _onRemoveKeyword(RemoveKeywordEvent event, Emitter<ContentImportState> emit) {
    final keywords = List<String>.from(state.content.keywords);
    keywords.remove(event.keyword);
    emit(state.copyWith(
      content: state.content.copyWith(keywords: keywords),
    ));
  }

  Future<void> _onSubmitContent(SubmitContentEvent event, Emitter<ContentImportState> emit) async {
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

    emit(state.copyWith(status: ContentImportStatus.submitting));

    try {
      // TODO: Implementar llamada al API para guardar el contenido
      // final result = await contentRepository.createSignContent(state.content);

      // Simulación de guardado
      await Future.delayed(const Duration(seconds: 2));

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
        errorMessage: 'Error al guardar contenido: $e',
      ));
    }
  }

  void _onResetForm(ResetFormEvent event, Emitter<ContentImportState> emit) {
    emit(ContentImportState(
      status: ContentImportStatus.editing,
      classId: state.classId,
      content: ContentImport(
        title: '',
        classId: state.classId,
      ),
    ));
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  Map<String, String?> _validateFields() {
    final errors = <String, String?>{};

    // Título siempre requerido
    if (state.content.title.isEmpty) {
      errors['title'] = 'El título es requerido';
    }

    // Video siempre requerido
    if (!state.content.hasVideo) {
      errors['videoUrl'] = 'La URL del video es requerida';
    } else if (!_isValidUrl(state.content.videoUrl!)) {
      errors['videoUrl'] = 'URL de video no válida';
    }

    // Validar URL de imagen si existe
    if (state.content.hasImage && !_isValidUrl(state.content.imageUrl!)) {
      errors['imageUrl'] = 'URL de imagen no válida';
    }

    // Validar URL de audio si existe
    if (state.content.hasAudio && !_isValidUrl(state.content.audioUrl!)) {
      errors['audioUrl'] = 'URL de audio no válida';
    }

    // Validaciones según tipo de contenido
    switch (state.content.contentType) {
      case SignContentType.dictionary:
        if (state.content.levelSectionId == null) {
          errors['levelSection'] = 'El nivel es requerido';
        }
        if (state.content.contentCategoryId == null) {
          errors['contentCategory'] = 'La categoría es requerida';
        }
        break;

      case SignContentType.commonPhrase:
        if (state.content.commonPhraseCategoryId == null) {
          errors['commonPhraseCategory'] = 'La categoría de frase es requerida';
        }
        if (state.content.phrase == null || state.content.phrase!.isEmpty) {
          errors['phrase'] = 'La frase es requerida';
        }
        break;

      case SignContentType.lesson:
        // Las lecciones no tienen validaciones adicionales por ahora
        break;
    }

    return errors;
  }
}
