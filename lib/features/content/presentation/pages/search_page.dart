import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entities.dart';
import '../bloc/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc(
      getModulesUseCase: sl(),
      getContentCategoriesUseCase: sl(),
      getLevelSectionsUseCase: sl(),
      getLessonsUseCase: sl(),
    );
    // Pre-load content for faster search
    _searchBloc.add(const LoadAllContentEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchBloc.add(SearchQueryChangedEvent(value));
  }

  void _clearSearch() {
    _searchController.clear();
    _searchBloc.add(const SearchClearedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Buscar señas, módulos o lecciones...',
              border: InputBorder.none,
              filled: false,
            ),
            onChanged: _onSearchChanged,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          ],
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is SearchEmptyState) {
              return _buildNoResults(state.query);
            }

            if (state is SearchResultsState) {
              return _buildResults(state);
            }

            if (state is SearchErrorState) {
              return _buildError(state.message);
            }

            // Initial state
            return _buildInitialState();
          },
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: AppColors.textHint),
          const SizedBox(height: AppDimensions.space),
          Text('Buscar contenido', style: AppTypography.titleMedium),
          const SizedBox(height: AppDimensions.spaceS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXL),
            child: Text(
              'Escribe para buscar señas, módulos o lecciones',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXL),
          _buildRecentSearches(),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    // Popular search suggestions
    final suggestions = [
      'Saludos',
      'Familia',
      'Números',
      'Colores',
      'Animales',
    ];

    return Column(
      children: [
        Text(
          'Sugerencias',
          style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Wrap(
          spacing: AppDimensions.spaceS,
          runSpacing: AppDimensions.spaceS,
          children: suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              onPressed: () {
                _searchController.text = suggestion;
                _onSearchChanged(suggestion);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textHint),
          const SizedBox(height: AppDimensions.space),
          Text('Sin resultados', style: AppTypography.titleMedium),
          const SizedBox(height: AppDimensions.spaceS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXL),
            child: Text(
              'No encontramos resultados para "$query"',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            'Intenta con otras palabras',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchResultsState state) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space),
      children: [
        // Header with result count
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space),
          child: Text(
            '${state.totalResults} resultados para "${state.query}"',
            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),

        // Categories section
        if (state.categories.isNotEmpty) ...[
          _buildSectionHeader('Categorías', Icons.category),
          ...state.categories.map((category) => _buildCategoryTile(category)),
          const SizedBox(height: AppDimensions.space),
        ],

        // Modules section
        if (state.modules.isNotEmpty) ...[
          _buildSectionHeader('Módulos', Icons.folder_outlined),
          ...state.modules.map((module) => _buildModuleTile(module)),
          const SizedBox(height: AppDimensions.space),
        ],

        // Lessons section
        if (state.lessons.isNotEmpty) ...[
          _buildSectionHeader('Lecciones', Icons.school_outlined),
          ...state.lessons.map((lesson) => _buildLessonTile(lesson)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spaceS,
        bottom: AppDimensions.spaceS,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spaceS),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(ContentCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: category.iconUrl != null
              ? Image.network(category.iconUrl!, width: 24, height: 24)
              : const Icon(Icons.category, color: AppColors.primary),
        ),
        title: Text(category.name, style: AppTypography.bodyLarge),
        subtitle: category.description != null
            ? Text(
                category.description!,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to category content
          AppNavigator.pushNamed(AppRoutes.home);
        },
      ),
    );
  }

  Widget _buildModuleTile(Module module) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          child: module.thumbnailUrl != null
              ? Image.network(
                  module.thumbnailUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderIcon(Icons.folder_outlined),
                )
              : _buildPlaceholderIcon(Icons.folder_outlined),
        ),
        title: Text(module.title, style: AppTypography.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (module.description != null)
              Text(
                module.description!,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '${module.lessonsCount} lecciones',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          AppNavigator.pushNamed(
            AppRoutes.moduleDetail,
            arguments: module.id,
          );
        },
      ),
    );
  }

  Widget _buildLessonTile(Lesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ListTile(
        leading: _buildPlaceholderIcon(Icons.school_outlined),
        title: Text(lesson.title, style: AppTypography.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lesson.description != null)
              Text(
                lesson.description!,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (lesson.duration != null) ...[
                  Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '${lesson.duration} min',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                ],
                Text(
                  '${lesson.activitiesCount} actividades',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ],
        ),
        trailing: lesson.isCompleted
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.chevron_right),
        onTap: () {
          AppNavigator.pushNamed(
            AppRoutes.activity,
            arguments: {
              'lessonId': lesson.id,
              'lessonTitle': lesson.title,
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: AppDimensions.space),
          Text('Error', style: AppTypography.titleMedium),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
