import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/translator_entities.dart';

// ============================================
// Events
// ============================================

abstract class TranslatorEvent extends Equatable {
  const TranslatorEvent();

  @override
  List<Object?> get props => [];
}

class TranslateTextEvent extends TranslatorEvent {
  final String text;
  const TranslateTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class ClearTranslationEvent extends TranslatorEvent {
  const ClearTranslationEvent();
}

class LoadHistoryEvent extends TranslatorEvent {
  const LoadHistoryEvent();
}

class ClearHistoryEvent extends TranslatorEvent {
  const ClearHistoryEvent();
}

class SelectHistoryItemEvent extends TranslatorEvent {
  final TranslationHistory item;
  const SelectHistoryItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// ============================================
// State
// ============================================

enum TranslatorStatus {
  initial,
  loading,
  success,
  notFound,
  error,
}

class TranslatorState extends Equatable {
  final TranslatorStatus status;
  final String inputText;
  final TranslationResult? result;
  final List<TranslationHistory> history;
  final String? errorMessage;
  final int currentLetterIndex; // Para animación de deletreo

  const TranslatorState({
    this.status = TranslatorStatus.initial,
    this.inputText = '',
    this.result,
    this.history = const [],
    this.errorMessage,
    this.currentLetterIndex = 0,
  });

  TranslatorState copyWith({
    TranslatorStatus? status,
    String? inputText,
    TranslationResult? result,
    List<TranslationHistory>? history,
    String? errorMessage,
    int? currentLetterIndex,
  }) {
    return TranslatorState(
      status: status ?? this.status,
      inputText: inputText ?? this.inputText,
      result: result ?? this.result,
      history: history ?? this.history,
      errorMessage: errorMessage,
      currentLetterIndex: currentLetterIndex ?? this.currentLetterIndex,
    );
  }

  @override
  List<Object?> get props => [
        status,
        inputText,
        result,
        history,
        errorMessage,
        currentLetterIndex,
      ];
}

// ============================================
// BLoC
// ============================================

class TranslatorBloc extends Bloc<TranslatorEvent, TranslatorState> {
  final SharedPreferences _prefs;

  static const String _historyKey = 'translation_history';
  static const int _maxHistoryItems = 20;

  // Diccionario simulado (en producción vendría del servidor)
  static const Map<String, SignTranslation> _dictionary = {
    'hola': SignTranslation(
      word: 'Hola',
      videoUrl: 'assets/videos/hola.mp4',
      imageUrl: 'assets/images/signs/hola.png',
      description: 'Saludo común',
      category: 'Saludos',
    ),
    'gracias': SignTranslation(
      word: 'Gracias',
      videoUrl: 'assets/videos/gracias.mp4',
      imageUrl: 'assets/images/signs/gracias.png',
      description: 'Expresión de agradecimiento',
      category: 'Cortesía',
    ),
    'adios': SignTranslation(
      word: 'Adiós',
      videoUrl: 'assets/videos/adios.mp4',
      imageUrl: 'assets/images/signs/adios.png',
      description: 'Despedida',
      category: 'Saludos',
    ),
    'por favor': SignTranslation(
      word: 'Por favor',
      videoUrl: 'assets/videos/por_favor.mp4',
      imageUrl: 'assets/images/signs/por_favor.png',
      description: 'Expresión de cortesía',
      category: 'Cortesía',
    ),
    'si': SignTranslation(
      word: 'Sí',
      videoUrl: 'assets/videos/si.mp4',
      imageUrl: 'assets/images/signs/si.png',
      description: 'Afirmación',
      category: 'Básico',
    ),
    'no': SignTranslation(
      word: 'No',
      videoUrl: 'assets/videos/no.mp4',
      imageUrl: 'assets/images/signs/no.png',
      description: 'Negación',
      category: 'Básico',
    ),
    'mama': SignTranslation(
      word: 'Mamá',
      videoUrl: 'assets/videos/mama.mp4',
      imageUrl: 'assets/images/signs/mama.png',
      description: 'Madre',
      category: 'Familia',
    ),
    'papa': SignTranslation(
      word: 'Papá',
      videoUrl: 'assets/videos/papa.mp4',
      imageUrl: 'assets/images/signs/papa.png',
      description: 'Padre',
      category: 'Familia',
    ),
    'agua': SignTranslation(
      word: 'Agua',
      videoUrl: 'assets/videos/agua.mp4',
      imageUrl: 'assets/images/signs/agua.png',
      description: 'Líquido vital',
      category: 'Alimentos',
    ),
    'comida': SignTranslation(
      word: 'Comida',
      videoUrl: 'assets/videos/comida.mp4',
      imageUrl: 'assets/images/signs/comida.png',
      description: 'Alimento',
      category: 'Alimentos',
    ),
    'amor': SignTranslation(
      word: 'Amor',
      videoUrl: 'assets/videos/amor.mp4',
      imageUrl: 'assets/images/signs/amor.png',
      description: 'Sentimiento de afecto',
      category: 'Emociones',
    ),
    'casa': SignTranslation(
      word: 'Casa',
      videoUrl: 'assets/videos/casa.mp4',
      imageUrl: 'assets/images/signs/casa.png',
      description: 'Hogar',
      category: 'Casa',
    ),
    'escuela': SignTranslation(
      word: 'Escuela',
      videoUrl: 'assets/videos/escuela.mp4',
      imageUrl: 'assets/images/signs/escuela.png',
      description: 'Centro educativo',
      category: 'Escuela',
    ),
    'amigo': SignTranslation(
      word: 'Amigo',
      videoUrl: 'assets/videos/amigo.mp4',
      imageUrl: 'assets/images/signs/amigo.png',
      description: 'Compañero',
      category: 'Relaciones',
    ),
    'buenos dias': SignTranslation(
      word: 'Buenos días',
      videoUrl: 'assets/videos/buenos_dias.mp4',
      imageUrl: 'assets/images/signs/buenos_dias.png',
      description: 'Saludo matutino',
      category: 'Saludos',
    ),
    'buenas noches': SignTranslation(
      word: 'Buenas noches',
      videoUrl: 'assets/videos/buenas_noches.mp4',
      imageUrl: 'assets/images/signs/buenas_noches.png',
      description: 'Saludo nocturno',
      category: 'Saludos',
    ),
    'como estas': SignTranslation(
      word: '¿Cómo estás?',
      videoUrl: 'assets/videos/como_estas.mp4',
      imageUrl: 'assets/images/signs/como_estas.png',
      description: 'Pregunta por el bienestar',
      category: 'Frases comunes',
    ),
    'bien': SignTranslation(
      word: 'Bien',
      videoUrl: 'assets/videos/bien.mp4',
      imageUrl: 'assets/images/signs/bien.png',
      description: 'Estado positivo',
      category: 'Básico',
    ),
    'mal': SignTranslation(
      word: 'Mal',
      videoUrl: 'assets/videos/mal.mp4',
      imageUrl: 'assets/images/signs/mal.png',
      description: 'Estado negativo',
      category: 'Básico',
    ),
    'feliz': SignTranslation(
      word: 'Feliz',
      videoUrl: 'assets/videos/feliz.mp4',
      imageUrl: 'assets/images/signs/feliz.png',
      description: 'Emoción de alegría',
      category: 'Emociones',
    ),
    'triste': SignTranslation(
      word: 'Triste',
      videoUrl: 'assets/videos/triste.mp4',
      imageUrl: 'assets/images/signs/triste.png',
      description: 'Emoción de tristeza',
      category: 'Emociones',
    ),
  };

  TranslatorBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const TranslatorState()) {
    on<TranslateTextEvent>(_onTranslateText);
    on<ClearTranslationEvent>(_onClearTranslation);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<ClearHistoryEvent>(_onClearHistory);
    on<SelectHistoryItemEvent>(_onSelectHistoryItem);
  }

  Future<void> _onTranslateText(
    TranslateTextEvent event,
    Emitter<TranslatorState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(state.copyWith(
      status: TranslatorStatus.loading,
      inputText: text,
    ));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Normalizar texto para búsqueda
      final normalizedText = _normalizeText(text);
      
      // Buscar en diccionario
      final translations = <SignTranslation>[];
      final words = normalizedText.split(' ');
      
      // Intentar traducción de frase completa primero
      if (_dictionary.containsKey(normalizedText)) {
        translations.add(_dictionary[normalizedText]!);
      } else {
        // Traducir palabra por palabra
        for (final word in words) {
          if (_dictionary.containsKey(word)) {
            translations.add(_dictionary[word]!);
          }
        }
      }

      TranslationResult result;
      
      if (translations.isNotEmpty) {
        // Traducción directa encontrada
        result = TranslationResult(
          inputText: text,
          type: TranslationType.direct,
          translations: translations,
        );
      } else {
        // No encontrado - usar dactilología (deletreo)
        final dactylology = DactylologyAlphabet.spellWord(text);
        result = TranslationResult(
          inputText: text,
          type: TranslationType.dactylology,
          translations: [],
          dactylology: dactylology,
        );
      }

      // Guardar en historial
      await _addToHistory(text, result.type);

      emit(state.copyWith(
        status: TranslatorStatus.success,
        result: result,
        currentLetterIndex: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TranslatorStatus.error,
        errorMessage: 'Error al traducir: $e',
      ));
    }
  }

  void _onClearTranslation(
    ClearTranslationEvent event,
    Emitter<TranslatorState> emit,
  ) {
    emit(const TranslatorState());
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<TranslatorState> emit,
  ) async {
    try {
      final historyJson = _prefs.getStringList(_historyKey) ?? [];
      final history = historyJson.map((json) {
        return TranslationHistory.fromJson(jsonDecode(json));
      }).toList();

      emit(state.copyWith(history: history));
    } catch (e) {
      // Ignorar errores de historial
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<TranslatorState> emit,
  ) async {
    await _prefs.remove(_historyKey);
    emit(state.copyWith(history: []));
  }

  void _onSelectHistoryItem(
    SelectHistoryItemEvent event,
    Emitter<TranslatorState> emit,
  ) {
    add(TranslateTextEvent(event.item.text));
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }

  Future<void> _addToHistory(String text, TranslationType type) async {
    final history = List<TranslationHistory>.from(state.history);
    
    // Evitar duplicados recientes
    history.removeWhere((h) => h.text.toLowerCase() == text.toLowerCase());
    
    // Agregar al inicio
    history.insert(
      0,
      TranslationHistory(
        text: text,
        timestamp: DateTime.now(),
        type: type,
      ),
    );

    // Limitar tamaño
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    // Guardar
    final historyJson = history.map((h) => jsonEncode(h.toJson())).toList();
    await _prefs.setStringList(_historyKey, historyJson);
  }
}
