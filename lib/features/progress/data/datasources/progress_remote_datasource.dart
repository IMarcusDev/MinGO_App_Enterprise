import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/progress_entities.dart';
import '../models/progress_models.dart';

abstract class ProgressRemoteDataSource {
  Future<LessonProgressModel> recordAttempt(RecordAttemptParams params);
  Future<CompleteLessonResultModel> completeLesson(CompleteLessonParams params);
  Future<List<LessonProgressModel>> getUserProgress({String? lessonId});
  Future<UserStatsModel> getUserStats();
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final ApiClient apiClient;

  ProgressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LessonProgressModel> recordAttempt(RecordAttemptParams params) async {
    final response = await apiClient.post(
      '/progress/attempt',
      data: params.toJson(),
    );

    if (response.statusCode == 201) {
      return LessonProgressModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al registrar intento',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<CompleteLessonResultModel> completeLesson(CompleteLessonParams params) async {
    final response = await apiClient.post(
      '/progress/complete',
      data: params.toJson(),
    );

    if (response.statusCode == 201) {
      return CompleteLessonResultModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al completar lección',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<LessonProgressModel>> getUserProgress({String? lessonId}) async {
    final queryParams = <String, dynamic>{};
    if (lessonId != null) {
      queryParams['lessonId'] = lessonId;
    }

    final response = await apiClient.get(
      '/progress',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => LessonProgressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener progreso',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<UserStatsModel> getUserStats() async {
    final response = await apiClient.get('/progress/stats');

    if (response.statusCode == 200) {
      return UserStatsModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: 'Error al obtener estadísticas',
      statusCode: response.statusCode,
    );
  }
}
