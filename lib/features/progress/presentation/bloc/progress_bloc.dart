import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/progress_entities.dart';
import '../../domain/usecases/progress_usecases.dart';

// ============================================
// EVENTS
// ============================================
abstract class ProgressEvent extends Equatable {
  const ProgressEvent();
  @override
  List<Object?> get props => [];
}

class LoadProgressEvent extends ProgressEvent {
  const LoadProgressEvent();
}

class LoadStatsEvent extends ProgressEvent {
  const LoadStatsEvent();
}

class LoadStreakEvent extends ProgressEvent {
  const LoadStreakEvent();
}

class LoadDailyActivityEvent extends ProgressEvent {
  final int days;
  const LoadDailyActivityEvent({this.days = 7});
  @override
  List<Object?> get props => [days];
}

class LoadAllProgressDataEvent extends ProgressEvent {
  const LoadAllProgressDataEvent();
}

class RecordAttemptEvent extends ProgressEvent {
  final RecordAttemptParams params;
  const RecordAttemptEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class CompleteLessonEvent extends ProgressEvent {
  final CompleteLessonParams params;
  const CompleteLessonEvent(this.params);
  @override
  List<Object?> get props => [params];
}

// ============================================
// STATES
// ============================================
abstract class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object?> get props => [];
}

class ProgressInitialState extends ProgressState {
  const ProgressInitialState();
}

class ProgressLoadingState extends ProgressState {
  final String? message;
  const ProgressLoadingState({this.message});
  @override
  List<Object?> get props => [message];
}

/// Estado con todos los datos de progreso cargados
class ProgressLoadedState extends ProgressState {
  final UserStats? stats;
  final List<LessonProgress> progress;
  final Streak? streak;
  final List<DailyActivity> dailyActivity;

  const ProgressLoadedState({
    this.stats,
    this.progress = const [],
    this.streak,
    this.dailyActivity = const [],
  });

  ProgressLoadedState copyWith({
    UserStats? stats,
    List<LessonProgress>? progress,
    Streak? streak,
    List<DailyActivity>? dailyActivity,
  }) {
    return ProgressLoadedState(
      stats: stats ?? this.stats,
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
      dailyActivity: dailyActivity ?? this.dailyActivity,
    );
  }

  @override
  List<Object?> get props => [stats, progress, streak, dailyActivity];
}

class AttemptRecordedState extends ProgressState {
  final LessonProgress progress;
  const AttemptRecordedState(this.progress);
  @override
  List<Object?> get props => [progress];
}

class LessonCompletedState extends ProgressState {
  final CompleteLessonResult result;
  const LessonCompletedState(this.result);
  @override
  List<Object?> get props => [result];
}

class ProgressErrorState extends ProgressState {
  final String message;
  const ProgressErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ============================================
// BLOC
// ============================================
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetUserProgressUseCase getUserProgressUseCase;
  final GetUserStatsUseCase getUserStatsUseCase;
  final GetStreakUseCase getStreakUseCase;
  final GetDailyActivityUseCase getDailyActivityUseCase;
  final RecordAttemptUseCase recordAttemptUseCase;
  final CompleteLessonUseCase completeLessonUseCase;

  ProgressBloc({
    required this.getUserProgressUseCase,
    required this.getUserStatsUseCase,
    required this.getStreakUseCase,
    required this.getDailyActivityUseCase,
    required this.recordAttemptUseCase,
    required this.completeLessonUseCase,
  }) : super(const ProgressInitialState()) {
    on<LoadAllProgressDataEvent>(_onLoadAllProgressData);
    on<LoadProgressEvent>(_onLoadProgress);
    on<LoadStatsEvent>(_onLoadStats);
    on<LoadStreakEvent>(_onLoadStreak);
    on<LoadDailyActivityEvent>(_onLoadDailyActivity);
    on<RecordAttemptEvent>(_onRecordAttempt);
    on<CompleteLessonEvent>(_onCompleteLesson);
  }

  Future<void> _onLoadAllProgressData(
    LoadAllProgressDataEvent event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoadingState(message: 'Cargando datos...'));

    UserStats? stats;
    List<LessonProgress> progress = [];
    Streak? streak;
    List<DailyActivity> dailyActivity = [];

    // Cargar estadísticas
    final statsResult = await getUserStatsUseCase();
    statsResult.fold(
      (failure) => null,
      (data) => stats = data,
    );

    // Cargar progreso
    final progressResult = await getUserProgressUseCase();
    progressResult.fold(
      (failure) => null,
      (data) => progress = data,
    );

    // Cargar racha
    final streakResult = await getStreakUseCase();
    streakResult.fold(
      (failure) => null,
      (data) => streak = data,
    );

    // Cargar actividad diaria (últimos 7 días)
    final activityResult = await getDailyActivityUseCase(7);
    activityResult.fold(
      (failure) => null,
      (data) => dailyActivity = data,
    );

    emit(ProgressLoadedState(
      stats: stats,
      progress: progress,
      streak: streak,
      dailyActivity: dailyActivity,
    ));
  }

  Future<void> _onLoadProgress(
    LoadProgressEvent event,
    Emitter<ProgressState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProgressLoadedState) {
      emit(const ProgressLoadingState());
    }

    final result = await getUserProgressUseCase();

    result.fold(
      (failure) => emit(ProgressErrorState(failure.message)),
      (progress) {
        if (currentState is ProgressLoadedState) {
          emit(currentState.copyWith(progress: progress));
        } else {
          emit(ProgressLoadedState(progress: progress));
        }
      },
    );
  }

  Future<void> _onLoadStats(
    LoadStatsEvent event,
    Emitter<ProgressState> emit,
  ) async {
    final currentState = state;
    final result = await getUserStatsUseCase();

    result.fold(
      (failure) => emit(ProgressErrorState(failure.message)),
      (stats) {
        if (currentState is ProgressLoadedState) {
          emit(currentState.copyWith(stats: stats));
        } else {
          emit(ProgressLoadedState(stats: stats));
        }
      },
    );
  }

  Future<void> _onLoadStreak(
    LoadStreakEvent event,
    Emitter<ProgressState> emit,
  ) async {
    final currentState = state;
    final result = await getStreakUseCase();

    result.fold(
      (failure) => emit(ProgressErrorState(failure.message)),
      (streak) {
        if (currentState is ProgressLoadedState) {
          emit(currentState.copyWith(streak: streak));
        } else {
          emit(ProgressLoadedState(streak: streak));
        }
      },
    );
  }

  Future<void> _onLoadDailyActivity(
    LoadDailyActivityEvent event,
    Emitter<ProgressState> emit,
  ) async {
    final currentState = state;
    final result = await getDailyActivityUseCase(event.days);

    result.fold(
      (failure) => emit(ProgressErrorState(failure.message)),
      (activity) {
        if (currentState is ProgressLoadedState) {
          emit(currentState.copyWith(dailyActivity: activity));
        } else {
          emit(ProgressLoadedState(dailyActivity: activity));
        }
      },
    );
  }

  Future<void> _onRecordAttempt(
    RecordAttemptEvent event,
    Emitter<ProgressState> emit,
  ) async {
    final result = await recordAttemptUseCase(event.params);

    result.fold(
      (failure) => emit(ProgressErrorState(failure.message)),
      (progress) => emit(AttemptRecordedState(progress)),
    );
  }

  Future<void> _onCompleteLesson(
    CompleteLessonEvent event,
    Emitter<ProgressState> emit,
  ) async {
    final result = await completeLessonUseCase(event.params);

    result.fold(
      (failure) => emit(ProgressErrorState(failure.message)),
      (completionResult) => emit(LessonCompletedState(completionResult)),
    );
  }
}
