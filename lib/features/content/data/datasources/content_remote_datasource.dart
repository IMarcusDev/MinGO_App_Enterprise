import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/content_models.dart';

/// Datasource remoto para contenido educativo
abstract class ContentRemoteDataSource {
  Future<List<AgeCategoryModel>> getAgeCategories();
  Future<List<LevelSectionModel>> getLevelSections();
  Future<List<ContentCategoryModel>> getContentCategories();
  Future<List<ModuleModel>> getModules({String? levelSectionId});
  Future<List<LessonModel>> getLessons(String moduleId);
  Future<LessonModel> getLessonById(String lessonId);
  Future<List<ActivityModel>> getActivities(String lessonId);
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final ApiClient apiClient;

  ContentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AgeCategoryModel>> getAgeCategories() async {
    final response = await apiClient.get('/content/age-categories');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AgeCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener categorías de edad',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<LevelSectionModel>> getLevelSections() async {
    final response = await apiClient.get('/content/levels');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => LevelSectionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener niveles',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<ContentCategoryModel>> getContentCategories() async {
    final response = await apiClient.get('/content/categories');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ContentCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener categorías',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<ModuleModel>> getModules({String? levelSectionId}) async {
    final queryParams = <String, dynamic>{};
    if (levelSectionId != null) {
      queryParams['levelSectionId'] = levelSectionId;
    }

    final response = await apiClient.get(
      '/content/modules',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ModuleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener módulos',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<LessonModel>> getLessons(String moduleId) async {
    final response = await apiClient.get('/content/modules/$moduleId/lessons');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => LessonModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener lecciones',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<LessonModel> getLessonById(String lessonId) async {
    final response = await apiClient.get('/content/lessons/$lessonId');

    if (response.statusCode == 200) {
      return LessonModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: 'Lección no encontrada',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<ActivityModel>> getActivities(String lessonId) async {
    final response = await apiClient.get('/content/lessons/$lessonId/activities');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener actividades',
      statusCode: response.statusCode,
    );
  }
}
