import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/achievement_entities.dart';
import '../../domain/repositories/achievement_repository.dart';

// ============================================
// Events
// ============================================

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAchievementsEvent extends AchievementEvent {
  const LoadAchievementsEvent();
}

class CheckAchievementsEvent extends AchievementEvent {
  final int lessonsCompleted;
  final int currentStreak;
  final int perfectScores;
  final int modulesCompleted;

  const CheckAchievementsEvent({
    required this.lessonsCompleted,
    required this.currentStreak,
    required this.perfectScores,
    required this.modulesCompleted,
  });

  @override
  List<Object?> get props => [
        lessonsCompleted,
        currentStreak,
        perfectScores,
        modulesCompleted,
      ];
}

class DismissNewAchievementEvent extends AchievementEvent {
  const DismissNewAchievementEvent();
}

// ============================================
// States
// ============================================

abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object?> get props => [];
}

class AchievementInitialState extends AchievementState {
  const AchievementInitialState();
}

class AchievementLoadingState extends AchievementState {
  const AchievementLoadingState();
}

class AchievementLoadedState extends AchievementState {
  final AchievementsSummary summary;
  final UnlockedAchievement? newlyUnlocked;

  const AchievementLoadedState({
    required this.summary,
    this.newlyUnlocked,
  });

  AchievementLoadedState copyWith({
    AchievementsSummary? summary,
    UnlockedAchievement? newlyUnlocked,
    bool clearNewlyUnlocked = false,
  }) {
    return AchievementLoadedState(
      summary: summary ?? this.summary,
      newlyUnlocked: clearNewlyUnlocked ? null : newlyUnlocked ?? this.newlyUnlocked,
    );
  }

  @override
  List<Object?> get props => [summary, newlyUnlocked];
}

class AchievementUnlockedState extends AchievementState {
  final List<UnlockedAchievement> newAchievements;
  final AchievementsSummary summary;

  const AchievementUnlockedState({
    required this.newAchievements,
    required this.summary,
  });

  @override
  List<Object?> get props => [newAchievements, summary];
}

class AchievementErrorState extends AchievementState {
  final String message;

  const AchievementErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================
// BLoC
// ============================================

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementRepository repository;

  AchievementBloc({required this.repository})
      : super(const AchievementInitialState()) {
    on<LoadAchievementsEvent>(_onLoadAchievements);
    on<CheckAchievementsEvent>(_onCheckAchievements);
    on<DismissNewAchievementEvent>(_onDismissNewAchievement);
  }

  Future<void> _onLoadAchievements(
    LoadAchievementsEvent event,
    Emitter<AchievementState> emit,
  ) async {
    emit(const AchievementLoadingState());

    final result = await repository.getUserAchievementsSummary();

    result.fold(
      (failure) => emit(AchievementErrorState(message: failure.message)),
      (summary) => emit(AchievementLoadedState(summary: summary)),
    );
  }

  Future<void> _onCheckAchievements(
    CheckAchievementsEvent event,
    Emitter<AchievementState> emit,
  ) async {
    final checkResult = await repository.checkAndUnlockAchievements(
      lessonsCompleted: event.lessonsCompleted,
      currentStreak: event.currentStreak,
      perfectScores: event.perfectScores,
      modulesCompleted: event.modulesCompleted,
    );

    await checkResult.fold(
      (failure) async {},
      (newlyUnlocked) async {
        if (newlyUnlocked.isNotEmpty) {
          // Recargar el resumen
          final summaryResult = await repository.getUserAchievementsSummary();
          summaryResult.fold(
            (failure) => emit(AchievementErrorState(message: failure.message)),
            (summary) => emit(AchievementUnlockedState(
              newAchievements: newlyUnlocked,
              summary: summary,
            )),
          );
        }
      },
    );
  }

  void _onDismissNewAchievement(
    DismissNewAchievementEvent event,
    Emitter<AchievementState> emit,
  ) {
    if (state is AchievementLoadedState) {
      emit((state as AchievementLoadedState).copyWith(clearNewlyUnlocked: true));
    }
  }
}
