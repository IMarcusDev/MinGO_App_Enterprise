import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/content_entities.dart';
import '../../domain/usecases/content_usecases.dart';

// ============================================
// EVENTS
// ============================================
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChangedEvent extends SearchEvent {
  final String query;
  const SearchQueryChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchClearedEvent extends SearchEvent {
  const SearchClearedEvent();
}

class LoadAllContentEvent extends SearchEvent {
  const LoadAllContentEvent();
}

// ============================================
// STATES
// ============================================
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitialState extends SearchState {
  const SearchInitialState();
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

class SearchEmptyState extends SearchState {
  final String query;
  const SearchEmptyState(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchResultsState extends SearchState {
  final String query;
  final List<Module> modules;
  final List<Lesson> lessons;
  final List<ContentCategory> categories;

  const SearchResultsState({
    required this.query,
    required this.modules,
    required this.lessons,
    required this.categories,
  });

  int get totalResults => modules.length + lessons.length + categories.length;

  @override
  List<Object?> get props => [query, modules, lessons, categories];
}

class SearchErrorState extends SearchState {
  final String message;
  const SearchErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ============================================
// BLOC
// ============================================
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetModulesUseCase getModulesUseCase;
  final GetContentCategoriesUseCase getContentCategoriesUseCase;
  final GetLevelSectionsUseCase getLevelSectionsUseCase;
  final GetLessonsUseCase getLessonsUseCase;

  // Cached content for local search
  List<Module> _allModules = [];
  List<ContentCategory> _allCategories = [];
  List<Lesson> _allLessons = [];
  bool _contentLoaded = false;

  SearchBloc({
    required this.getModulesUseCase,
    required this.getContentCategoriesUseCase,
    required this.getLevelSectionsUseCase,
    required this.getLessonsUseCase,
  }) : super(const SearchInitialState()) {
    on<LoadAllContentEvent>(_onLoadAllContent);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<SearchClearedEvent>(_onSearchCleared);
  }

  Future<void> _onLoadAllContent(
    LoadAllContentEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (_contentLoaded) return;

    emit(const SearchLoadingState());

    // Load modules
    final modulesResult = await getModulesUseCase();
    modulesResult.fold(
      (failure) => null,
      (modules) => _allModules = modules,
    );

    // Load categories
    final categoriesResult = await getContentCategoriesUseCase();
    categoriesResult.fold(
      (failure) => null,
      (categories) => _allCategories = categories,
    );

    // Load lessons from all modules
    for (final module in _allModules) {
      final lessonsResult = await getLessonsUseCase(module.id);
      lessonsResult.fold(
        (failure) => null,
        (lessons) => _allLessons.addAll(lessons),
      );
    }

    _contentLoaded = true;
    emit(const SearchInitialState());
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(const SearchInitialState());
      return;
    }

    if (query.length < 2) {
      return; // Wait for at least 2 characters
    }

    emit(const SearchLoadingState());

    // Load content if not already loaded
    if (!_contentLoaded) {
      final modulesResult = await getModulesUseCase();
      modulesResult.fold(
        (failure) => null,
        (modules) => _allModules = modules,
      );

      final categoriesResult = await getContentCategoriesUseCase();
      categoriesResult.fold(
        (failure) => null,
        (categories) => _allCategories = categories,
      );

      // Load lessons from all modules (limited to avoid too many requests)
      for (final module in _allModules.take(10)) {
        final lessonsResult = await getLessonsUseCase(module.id);
        lessonsResult.fold(
          (failure) => null,
          (lessons) => _allLessons.addAll(lessons),
        );
      }

      _contentLoaded = true;
    }

    // Search in modules
    final matchingModules = _allModules.where((module) {
      return module.title.toLowerCase().contains(query) ||
          (module.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Search in lessons
    final matchingLessons = _allLessons.where((lesson) {
      return lesson.title.toLowerCase().contains(query) ||
          (lesson.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Search in categories
    final matchingCategories = _allCategories.where((category) {
      return category.name.toLowerCase().contains(query) ||
          (category.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (matchingModules.isEmpty &&
        matchingLessons.isEmpty &&
        matchingCategories.isEmpty) {
      emit(SearchEmptyState(event.query));
    } else {
      emit(SearchResultsState(
        query: event.query,
        modules: matchingModules,
        lessons: matchingLessons,
        categories: matchingCategories,
      ));
    }
  }

  void _onSearchCleared(
    SearchClearedEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(const SearchInitialState());
  }
}
