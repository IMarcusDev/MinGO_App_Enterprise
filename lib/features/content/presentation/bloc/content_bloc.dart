import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/content_entities.dart';
import '../../domain/usecases/content_usecases.dart';

// ============================================
// EVENTS
// ============================================
abstract class ContentEvent extends Equatable {
  const ContentEvent();
  @override
  List<Object?> get props => [];
}

class LoadLevelSectionsEvent extends ContentEvent {
  const LoadLevelSectionsEvent();
}

class LoadModulesEvent extends ContentEvent {
  final String? levelSectionId;
  const LoadModulesEvent({this.levelSectionId});
  @override
  List<Object?> get props => [levelSectionId];
}

class LoadLessonsEvent extends ContentEvent {
  final String moduleId;
  const LoadLessonsEvent(this.moduleId);
  @override
  List<Object?> get props => [moduleId];
}

class LoadLessonDetailEvent extends ContentEvent {
  final String lessonId;
  const LoadLessonDetailEvent(this.lessonId);
  @override
  List<Object?> get props => [lessonId];
}

class LoadActivitiesEvent extends ContentEvent {
  final String lessonId;
  const LoadActivitiesEvent(this.lessonId);
  @override
  List<Object?> get props => [lessonId];
}

class LoadCategoriesEvent extends ContentEvent {
  const LoadCategoriesEvent();
}

// ============================================
// STATES
// ============================================
abstract class ContentState extends Equatable {
  const ContentState();
  @override
  List<Object?> get props => [];
}

class ContentInitialState extends ContentState {
  const ContentInitialState();
}

class ContentLoadingState extends ContentState {
  final String? message;
  const ContentLoadingState({this.message});
  @override
  List<Object?> get props => [message];
}

class LevelSectionsLoadedState extends ContentState {
  final List<LevelSection> levels;
  const LevelSectionsLoadedState(this.levels);
  @override
  List<Object?> get props => [levels];
}

class ModulesLoadedState extends ContentState {
  final List<Module> modules;
  const ModulesLoadedState(this.modules);
  @override
  List<Object?> get props => [modules];
}

class LessonsLoadedState extends ContentState {
  final List<Lesson> lessons;
  const LessonsLoadedState(this.lessons);
  @override
  List<Object?> get props => [lessons];
}

class LessonDetailLoadedState extends ContentState {
  final Lesson lesson;
  const LessonDetailLoadedState(this.lesson);
  @override
  List<Object?> get props => [lesson];
}

class ActivitiesLoadedState extends ContentState {
  final List<Activity> activities;
  const ActivitiesLoadedState(this.activities);
  @override
  List<Object?> get props => [activities];
}

class CategoriesLoadedState extends ContentState {
  final List<ContentCategory> categories;
  const CategoriesLoadedState(this.categories);
  @override
  List<Object?> get props => [categories];
}

class ContentErrorState extends ContentState {
  final String message;
  const ContentErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ============================================
// BLOC
// ============================================
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final GetLevelSectionsUseCase getLevelSectionsUseCase;
  final GetModulesUseCase getModulesUseCase;
  final GetLessonsUseCase getLessonsUseCase;
  final GetLessonDetailUseCase getLessonDetailUseCase;
  final GetActivitiesUseCase getActivitiesUseCase;
  final GetContentCategoriesUseCase getContentCategoriesUseCase;

  ContentBloc({
    required this.getLevelSectionsUseCase,
    required this.getModulesUseCase,
    required this.getLessonsUseCase,
    required this.getLessonDetailUseCase,
    required this.getActivitiesUseCase,
    required this.getContentCategoriesUseCase,
  }) : super(const ContentInitialState()) {
    on<LoadLevelSectionsEvent>(_onLoadLevelSections);
    on<LoadModulesEvent>(_onLoadModules);
    on<LoadLessonsEvent>(_onLoadLessons);
    on<LoadLessonDetailEvent>(_onLoadLessonDetail);
    on<LoadActivitiesEvent>(_onLoadActivities);
    on<LoadCategoriesEvent>(_onLoadCategories);
  }

  Future<void> _onLoadLevelSections(
    LoadLevelSectionsEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentLoadingState(message: 'Cargando niveles...'));

    final result = await getLevelSectionsUseCase();

    result.fold(
      (failure) => emit(ContentErrorState(failure.message)),
      (levels) => emit(LevelSectionsLoadedState(levels)),
    );
  }

  Future<void> _onLoadModules(
    LoadModulesEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentLoadingState(message: 'Cargando módulos...'));

    final result = await getModulesUseCase(levelSectionId: event.levelSectionId);

    result.fold(
      (failure) => emit(ContentErrorState(failure.message)),
      (modules) => emit(ModulesLoadedState(modules)),
    );
  }

  Future<void> _onLoadLessons(
    LoadLessonsEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentLoadingState(message: 'Cargando lecciones...'));

    final result = await getLessonsUseCase(event.moduleId);

    result.fold(
      (failure) => emit(ContentErrorState(failure.message)),
      (lessons) => emit(LessonsLoadedState(lessons)),
    );
  }

  Future<void> _onLoadLessonDetail(
    LoadLessonDetailEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentLoadingState(message: 'Cargando lección...'));

    final result = await getLessonDetailUseCase(event.lessonId);

    result.fold(
      (failure) => emit(ContentErrorState(failure.message)),
      (lesson) => emit(LessonDetailLoadedState(lesson)),
    );
  }

  Future<void> _onLoadActivities(
    LoadActivitiesEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentLoadingState(message: 'Cargando actividades...'));

    final result = await getActivitiesUseCase(event.lessonId);

    result.fold(
      (failure) => emit(ContentErrorState(failure.message)),
      (activities) => emit(ActivitiesLoadedState(activities)),
    );
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentLoadingState(message: 'Cargando categorías...'));

    final result = await getContentCategoriesUseCase();

    result.fold(
      (failure) => emit(ContentErrorState(failure.message)),
      (categories) => emit(CategoriesLoadedState(categories)),
    );
  }
}
