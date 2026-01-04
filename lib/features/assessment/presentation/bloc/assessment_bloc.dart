import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/assessment_questions.dart';
import '../../domain/entities/assessment_entities.dart';

// ============================================
// Events
// ============================================

abstract class AssessmentEvent extends Equatable {
  const AssessmentEvent();

  @override
  List<Object?> get props => [];
}

class StartAssessmentEvent extends AssessmentEvent {
  const StartAssessmentEvent();
}

class AnswerQuestionEvent extends AssessmentEvent {
  final int questionId;
  final int selectedOptionIndex;
  final int score;

  const AnswerQuestionEvent({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.score,
  });

  @override
  List<Object?> get props => [questionId, selectedOptionIndex, score];
}

class SetChildAgeEvent extends AssessmentEvent {
  final int age;

  const SetChildAgeEvent(this.age);

  @override
  List<Object?> get props => [age];
}

class NextQuestionEvent extends AssessmentEvent {
  const NextQuestionEvent();
}

class PreviousQuestionEvent extends AssessmentEvent {
  const PreviousQuestionEvent();
}

class SubmitAssessmentEvent extends AssessmentEvent {
  const SubmitAssessmentEvent();
}

class ResetAssessmentEvent extends AssessmentEvent {
  const ResetAssessmentEvent();
}

// ============================================
// State
// ============================================

enum AssessmentStatus { initial, inProgress, submitting, completed, error }

class AssessmentState extends Equatable {
  final AssessmentStatus status;
  final int currentQuestionIndex;
  final int childAge;
  final Map<int, AssessmentAnswer> answers;
  final AssessmentResult? result;
  final String? errorMessage;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.currentQuestionIndex = 0,
    this.childAge = 0,
    this.answers = const {},
    this.result,
    this.errorMessage,
  });

  /// Total de pasos (edad + preguntas)
  int get totalSteps => AssessmentQuestions.questions.length + 1;

  /// Paso actual (0 = edad, 1+ = preguntas)
  int get currentStep => currentQuestionIndex;

  /// Progreso (0.0 a 1.0)
  double get progress => (currentQuestionIndex + 1) / totalSteps;

  /// ¿Está en la pregunta de edad?
  bool get isAgeQuestion => currentQuestionIndex == 0;

  /// ¿Es la última pregunta?
  bool get isLastQuestion => currentQuestionIndex == totalSteps - 1;

  /// ¿Puede avanzar?
  bool get canProceed {
    if (isAgeQuestion) {
      return childAge >= 1 && childAge <= 12;
    }
    final questionId = AssessmentQuestions.questions[currentQuestionIndex - 1].id;
    return answers.containsKey(questionId);
  }

  /// Pregunta actual (null si es pregunta de edad)
  AssessmentQuestion? get currentQuestion {
    if (isAgeQuestion) return null;
    return AssessmentQuestions.questions[currentQuestionIndex - 1];
  }

  /// Puntaje total actual
  int get totalScore {
    return answers.values.fold(0, (sum, answer) => sum + answer.score);
  }

  AssessmentState copyWith({
    AssessmentStatus? status,
    int? currentQuestionIndex,
    int? childAge,
    Map<int, AssessmentAnswer>? answers,
    AssessmentResult? result,
    String? errorMessage,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      childAge: childAge ?? this.childAge,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentQuestionIndex,
        childAge,
        answers,
        result,
        errorMessage,
      ];
}

// ============================================
// BLoC
// ============================================

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final SharedPreferences _prefs;

  static const String _assessmentCompletedKey = 'assessment_completed';
  static const String _assignedLevelKey = 'assigned_level';
  static const String _childAgeKey = 'child_age';
  static const String _ageCategoryKey = 'age_category';

  AssessmentBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const AssessmentState()) {
    on<StartAssessmentEvent>(_onStartAssessment);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<SetChildAgeEvent>(_onSetChildAge);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<SubmitAssessmentEvent>(_onSubmitAssessment);
    on<ResetAssessmentEvent>(_onResetAssessment);
  }

  /// Verificar si ya completó la prueba
  bool get hasCompletedAssessment {
    return _prefs.getBool(_assessmentCompletedKey) ?? false;
  }

  /// Obtener nivel asignado
  String? get assignedLevel {
    return _prefs.getString(_assignedLevelKey);
  }

  /// Obtener edad del niño
  int? get savedChildAge {
    return _prefs.getInt(_childAgeKey);
  }

  void _onStartAssessment(
    StartAssessmentEvent event,
    Emitter<AssessmentState> emit,
  ) {
    emit(state.copyWith(
      status: AssessmentStatus.inProgress,
      currentQuestionIndex: 0,
      childAge: 0,
      answers: {},
      result: null,
    ));
  }

  void _onSetChildAge(
    SetChildAgeEvent event,
    Emitter<AssessmentState> emit,
  ) {
    emit(state.copyWith(childAge: event.age));
  }

  void _onAnswerQuestion(
    AnswerQuestionEvent event,
    Emitter<AssessmentState> emit,
  ) {
    final newAnswers = Map<int, AssessmentAnswer>.from(state.answers);
    newAnswers[event.questionId] = AssessmentAnswer(
      questionId: event.questionId,
      selectedOptionIndex: event.selectedOptionIndex,
      score: event.score,
    );
    emit(state.copyWith(answers: newAnswers));
  }

  void _onNextQuestion(
    NextQuestionEvent event,
    Emitter<AssessmentState> emit,
  ) {
    if (!state.canProceed) return;

    if (state.isLastQuestion) {
      add(const SubmitAssessmentEvent());
    } else {
      emit(state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      ));
    }
  }

  void _onPreviousQuestion(
    PreviousQuestionEvent event,
    Emitter<AssessmentState> emit,
  ) {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      ));
    }
  }

  Future<void> _onSubmitAssessment(
    SubmitAssessmentEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.submitting));

    try {
      final totalScore = state.totalScore;
      final level = AssessmentQuestions.getLevelFromScore(totalScore);
      final ageCategory = AssessmentQuestions.getAgeCategory(state.childAge);

      final result = AssessmentResult(
        totalScore: totalScore,
        maxPossibleScore: AssessmentQuestions.maxScore,
        assignedLevel: level,
        childAge: state.childAge,
        ageCategory: ageCategory,
        completedAt: DateTime.now(),
        answers: state.answers.values.toList(),
      );

      // Guardar en preferencias
      await _prefs.setBool(_assessmentCompletedKey, true);
      await _prefs.setString(_assignedLevelKey, level);
      await _prefs.setInt(_childAgeKey, state.childAge);
      await _prefs.setString(_ageCategoryKey, ageCategory);

      emit(state.copyWith(
        status: AssessmentStatus.completed,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: 'Error al procesar la prueba: $e',
      ));
    }
  }

  Future<void> _onResetAssessment(
    ResetAssessmentEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    await _prefs.remove(_assessmentCompletedKey);
    await _prefs.remove(_assignedLevelKey);
    await _prefs.remove(_childAgeKey);
    await _prefs.remove(_ageCategoryKey);

    emit(const AssessmentState());
  }
}
