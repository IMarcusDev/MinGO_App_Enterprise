import 'package:equatable/equatable.dart';

/// Resultado de traducción
class TranslationResult extends Equatable {
  final String inputText;
  final TranslationType type;
  final List<SignTranslation> translations;
  final List<DactylologyLetter>? dactylology;

  const TranslationResult({
    required this.inputText,
    required this.type,
    required this.translations,
    this.dactylology,
  });

  bool get isSpelling => type == TranslationType.dactylology;
  bool get hasTranslations => translations.isNotEmpty;

  @override
  List<Object?> get props => [inputText, type, translations, dactylology];
}

/// Tipo de traducción
enum TranslationType {
  direct, // Traducción directa (palabra existe en diccionario)
  dactylology, // Deletreo letra por letra
  mixed, // Combinación de ambos
}

/// Traducción de una seña
class SignTranslation extends Equatable {
  final String word;
  final String? videoUrl;
  final String? imageUrl;
  final String? description;
  final String category;

  const SignTranslation({
    required this.word,
    this.videoUrl,
    this.imageUrl,
    this.description,
    required this.category,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory SignTranslation.fromJson(Map<String, dynamic> json) {
    return SignTranslation(
      word: json['word'] ?? '',
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      description: json['description'],
      category: json['category'] ?? '',
    );
  }

  @override
  List<Object?> get props => [word, videoUrl, imageUrl, description, category];
}

/// Letra en dactilología (alfabeto manual)
class DactylologyLetter extends Equatable {
  final String letter;
  final String imageUrl;
  final String? description;

  const DactylologyLetter({
    required this.letter,
    required this.imageUrl,
    this.description,
  });

  @override
  List<Object?> get props => [letter, imageUrl, description];
}

/// Diccionario de dactilología (alfabeto manual LSEC)
class DactylologyAlphabet {
  static const String baseImagePath = 'assets/images/dactylology';

  /// Obtener todas las letras del alfabeto
  static List<DactylologyLetter> get alphabet {
    return 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'.split('').map((letter) {
      return DactylologyLetter(
        letter: letter,
        imageUrl: '$baseImagePath/${letter.toLowerCase()}.png',
        description: 'Letra $letter en Lengua de Señas Ecuatoriana',
      );
    }).toList();
  }

  /// Obtener dactilología para una palabra
  static List<DactylologyLetter> spellWord(String word) {
    return word.toUpperCase().split('').where((char) {
      return RegExp(r'[A-ZÑ]').hasMatch(char);
    }).map((letter) {
      return DactylologyLetter(
        letter: letter,
        imageUrl: '$baseImagePath/${letter.toLowerCase()}.png',
        description: 'Letra $letter',
      );
    }).toList();
  }
}

/// Historial de traducciones
class TranslationHistory extends Equatable {
  final String text;
  final DateTime timestamp;
  final TranslationType type;

  const TranslationHistory({
    required this.text,
    required this.timestamp,
    required this.type,
  });

  factory TranslationHistory.fromJson(Map<String, dynamic> json) {
    return TranslationHistory(
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      type: TranslationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TranslationType.direct,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  @override
  List<Object?> get props => [text, timestamp, type];
}
