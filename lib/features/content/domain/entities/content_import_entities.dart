import 'package:equatable/equatable.dart';

/// Tipo de contenido - Alineado con la base de datos
enum SignContentType {
  dictionary('dictionary'),
  lesson('lesson'),
  commonPhrase('common_phrase');

  final String value;
  const SignContentType(this.value);

  static SignContentType fromString(String value) {
    return SignContentType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => SignContentType.dictionary,
    );
  }

  String get displayName {
    switch (this) {
      case SignContentType.dictionary:
        return 'Diccionario (Principiante)';
      case SignContentType.lesson:
        return 'Lección (Intermedio/Avanzado)';
      case SignContentType.commonPhrase:
        return 'Frase Común';
    }
  }
}

/// Modelo para contenido multimedia a importar
/// Alineado con la tabla signs_content de la base de datos
class ContentImport extends Equatable {
  final String? id;
  final String title;

  // URLs de archivos
  final String? videoUrl;
  final String? imageUrl;
  final String? audioUrl;

  // Metadatos
  final String? phrase;          // Frase completa si es "Frases Comunes"
  final String? exampleSentence; // Oración de ejemplo
  final List<String> keywords;   // Palabras clave para búsqueda

  // Clasificación de contenido
  final SignContentType contentType;

  // Para contenido tipo DICTIONARY (Principiante)
  final String? levelSectionId;
  final String? contentCategoryId;

  // Para contenido tipo COMMON_PHRASE
  final String? commonPhraseCategoryId;

  // Edad aplicable
  final String? ageCategoryId;

  // Relación con clase (contenido importado por docente)
  final String? classId;

  // Control
  final bool isPremium;

  final DateTime? createdAt;
  final String? createdBy;

  const ContentImport({
    this.id,
    required this.title,
    this.videoUrl,
    this.imageUrl,
    this.audioUrl,
    this.phrase,
    this.exampleSentence,
    this.keywords = const [],
    this.contentType = SignContentType.dictionary,
    this.levelSectionId,
    this.contentCategoryId,
    this.commonPhraseCategoryId,
    this.ageCategoryId,
    this.classId,
    this.isPremium = false,
    this.createdAt,
    this.createdBy,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  bool get isValid {
    // Video siempre requerido
    if (!hasVideo) return false;
    // Título siempre requerido
    if (title.isEmpty) return false;

    // Validaciones según tipo de contenido
    switch (contentType) {
      case SignContentType.dictionary:
        return levelSectionId != null && contentCategoryId != null;
      case SignContentType.commonPhrase:
        return commonPhraseCategoryId != null && phrase != null && phrase!.isNotEmpty;
      case SignContentType.lesson:
        return true; // Las lecciones no requieren categorías adicionales
    }
  }

  ContentImport copyWith({
    String? id,
    String? title,
    String? videoUrl,
    String? imageUrl,
    String? audioUrl,
    String? phrase,
    String? exampleSentence,
    List<String>? keywords,
    SignContentType? contentType,
    String? levelSectionId,
    String? contentCategoryId,
    String? commonPhraseCategoryId,
    String? ageCategoryId,
    String? classId,
    bool? isPremium,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ContentImport(
      id: id ?? this.id,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      phrase: phrase ?? this.phrase,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      keywords: keywords ?? this.keywords,
      contentType: contentType ?? this.contentType,
      levelSectionId: levelSectionId ?? this.levelSectionId,
      contentCategoryId: contentCategoryId ?? this.contentCategoryId,
      commonPhraseCategoryId: commonPhraseCategoryId ?? this.commonPhraseCategoryId,
      ageCategoryId: ageCategoryId ?? this.ageCategoryId,
      classId: classId ?? this.classId,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Limpiar campos según el tipo de contenido seleccionado
  ContentImport clearForContentType(SignContentType newType) {
    switch (newType) {
      case SignContentType.dictionary:
        return copyWith(
          contentType: newType,
          commonPhraseCategoryId: null,
        );
      case SignContentType.commonPhrase:
        return copyWith(
          contentType: newType,
          levelSectionId: null,
          contentCategoryId: null,
        );
      case SignContentType.lesson:
        return copyWith(
          contentType: newType,
          levelSectionId: null,
          contentCategoryId: null,
          commonPhraseCategoryId: null,
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'video_url': videoUrl,
      'image_url': imageUrl,
      'audio_url': audioUrl,
      'phrase': phrase,
      'example_sentence': exampleSentence,
      'keywords': keywords,
      'content_type': contentType.value,
      'level_section_id': levelSectionId,
      'content_category_id': contentCategoryId,
      'common_phrase_category_id': commonPhraseCategoryId,
      'age_category_id': ageCategoryId,
      'class_id': classId,
      'is_premium': isPremium,
      'created_at': createdAt?.toIso8601String(),
      'uploaded_by': createdBy,
    };
  }

  factory ContentImport.fromJson(Map<String, dynamic> json) {
    return ContentImport(
      id: json['id'],
      title: json['title'] ?? '',
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      phrase: json['phrase'],
      exampleSentence: json['example_sentence'],
      keywords: List<String>.from(json['keywords'] ?? []),
      contentType: SignContentType.fromString(json['content_type'] ?? 'dictionary'),
      levelSectionId: json['level_section_id'],
      contentCategoryId: json['content_category_id'],
      commonPhraseCategoryId: json['common_phrase_category_id'],
      ageCategoryId: json['age_category_id'],
      classId: json['class_id'],
      isPremium: json['is_premium'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      createdBy: json['uploaded_by'],
    );
  }

  @override
  List<Object?> get props => [
    id, title, videoUrl, imageUrl, audioUrl, phrase, exampleSentence,
    keywords, contentType, levelSectionId, contentCategoryId,
    commonPhraseCategoryId, ageCategoryId, classId, isPremium, createdAt, createdBy,
  ];
}

/// Categorías disponibles para el contenido
class ContentCategories {
  /// Categorías para señas de diccionario (Principiante)
  static const List<String> signCategories = [
    'Saludos y despedidas',
    'Presentación',
    'Familia',
    'Animales',
    'Colores',
    'Números',
    'Alimentos',
    'Casa y hogar',
    'Transporte',
    'Escuela',
    'Emociones',
    'Acciones cotidianas',
    'Ropa',
    'Cuerpo humano',
    'Naturaleza',
    'Profesiones',
    'Días y meses',
    'Clima',
    'Deportes',
    'Costumbres ecuatorianas',
  ];

  /// Niveles de dificultad (secciones de nivel)
  static const List<Map<String, String>> levelSections = [
    {'id': 'principiante', 'name': 'Principiante'},
    {'id': 'intermedio', 'name': 'Intermedio'},
    {'id': 'avanzado', 'name': 'Avanzado'},
  ];

  /// Categorías para frases comunes
  static const List<String> commonPhraseCategories = [
    'Saludos y despedidas',
    'Presentación',
    'Frases de cortesía',
    'Rutinas del hogar',
    'Acciones comunes',
    'Preguntas frecuentes',
    'Expresiones de necesidad',
    'Emociones y sentimientos',
  ];

  /// Categorías de edad
  static const List<Map<String, dynamic>> ageCategories = [
    {'id': 'ninos', 'name': 'Niños (5-12 años)', 'minAge': 5, 'maxAge': 12},
    {'id': 'adolescentes', 'name': 'Adolescentes (13-17 años)', 'minAge': 13, 'maxAge': 17},
    {'id': 'adultos', 'name': 'Adultos (18+ años)', 'minAge': 18, 'maxAge': 99},
    {'id': 'todos', 'name': 'Todas las edades', 'minAge': 0, 'maxAge': 99},
  ];
}

/// Estado de la operación de importación
enum ContentImportStatus {
  initial,
  editing,
  validating,
  submitting,
  success,
  error,
}
