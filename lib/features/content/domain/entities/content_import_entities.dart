import 'package:equatable/equatable.dart';

/// Modelo para contenido multimedia a importar
class ContentImport extends Equatable {
  final String? id;
  final String title;
  final String phrase;
  final String category;
  final String level; // principiante, intermedio, avanzado, frases_comunes
  final List<String> keywords;
  final String? videoPath;
  final String? imagePath;
  final String? videoUrl;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? createdBy;

  const ContentImport({
    this.id,
    required this.title,
    required this.phrase,
    required this.category,
    required this.level,
    this.keywords = const [],
    this.videoPath,
    this.imagePath,
    this.videoUrl,
    this.imageUrl,
    this.createdAt,
    this.createdBy,
  });

  bool get hasVideo => videoPath != null || videoUrl != null;
  bool get hasImage => imagePath != null || imageUrl != null;
  bool get isValid => title.isNotEmpty && phrase.isNotEmpty && category.isNotEmpty && level.isNotEmpty;

  ContentImport copyWith({
    String? id,
    String? title,
    String? phrase,
    String? category,
    String? level,
    List<String>? keywords,
    String? videoPath,
    String? imagePath,
    String? videoUrl,
    String? imageUrl,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ContentImport(
      id: id ?? this.id,
      title: title ?? this.title,
      phrase: phrase ?? this.phrase,
      category: category ?? this.category,
      level: level ?? this.level,
      keywords: keywords ?? this.keywords,
      videoPath: videoPath ?? this.videoPath,
      imagePath: imagePath ?? this.imagePath,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'phrase': phrase,
      'category': category,
      'level': level,
      'keywords': keywords,
      'video_path': videoPath,
      'image_path': imagePath,
      'video_url': videoUrl,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }

  factory ContentImport.fromJson(Map<String, dynamic> json) {
    return ContentImport(
      id: json['id'],
      title: json['title'] ?? '',
      phrase: json['phrase'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      videoPath: json['video_path'],
      imagePath: json['image_path'],
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      createdBy: json['created_by'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        phrase,
        category,
        level,
        keywords,
        videoPath,
        imagePath,
        videoUrl,
        imageUrl,
        createdAt,
        createdBy,
      ];
}

/// Categorías disponibles para el contenido
class ContentCategories {
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

  static const List<String> levels = [
    'Principiante',
    'Intermedio',
    'Avanzado',
    'Frases comunes',
  ];

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
}

/// Estado de subida de archivo
enum UploadStatus {
  idle,
  selecting,
  uploading,
  success,
  error,
}

/// Progreso de importación
class ImportProgress extends Equatable {
  final UploadStatus videoStatus;
  final UploadStatus imageStatus;
  final double videoProgress;
  final double imageProgress;
  final String? errorMessage;

  const ImportProgress({
    this.videoStatus = UploadStatus.idle,
    this.imageStatus = UploadStatus.idle,
    this.videoProgress = 0,
    this.imageProgress = 0,
    this.errorMessage,
  });

  bool get isUploading =>
      videoStatus == UploadStatus.uploading ||
      imageStatus == UploadStatus.uploading;

  bool get hasError =>
      videoStatus == UploadStatus.error || imageStatus == UploadStatus.error;

  ImportProgress copyWith({
    UploadStatus? videoStatus,
    UploadStatus? imageStatus,
    double? videoProgress,
    double? imageProgress,
    String? errorMessage,
  }) {
    return ImportProgress(
      videoStatus: videoStatus ?? this.videoStatus,
      imageStatus: imageStatus ?? this.imageStatus,
      videoProgress: videoProgress ?? this.videoProgress,
      imageProgress: imageProgress ?? this.imageProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        videoStatus,
        imageStatus,
        videoProgress,
        imageProgress,
        errorMessage,
      ];
}
