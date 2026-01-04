import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/class_entities.dart';
import '../models/class_models.dart';

abstract class ClassRemoteDataSource {
  // Docente
  Future<SchoolClassModel> createClass(CreateClassParams params);
  Future<ClassListModel> getTeacherClasses();
  Future<SchoolClassModel> updateClass(String classId, UpdateClassParams params);
  Future<void> deleteClass(String classId);
  Future<AssignmentModel> createAssignment(String classId, CreateAssignmentParams params);
  Future<List<StudentProgressModel>> getClassStudents(String classId);
  
  // Estudiante
  Future<EnrollmentModel> joinClass(JoinClassParams params);
  Future<void> leaveClass(String classId);
  Future<ClassListModel> getEnrolledClasses();
  
  // Común
  Future<SchoolClassModel> getClassById(String classId);
  Future<List<AssignmentModel>> getClassAssignments(String classId);
}

class ClassRemoteDataSourceImpl implements ClassRemoteDataSource {
  final ApiClient apiClient;

  ClassRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SchoolClassModel> createClass(CreateClassParams params) async {
    final response = await apiClient.post('/classes', data: params.toJson());

    if (response.statusCode == 201) {
      return SchoolClassModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al crear clase',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ClassListModel> getTeacherClasses() async {
    final response = await apiClient.get('/classes/teaching');

    if (response.statusCode == 200) {
      return ClassListModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: 'Error al obtener clases',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<SchoolClassModel> updateClass(String classId, UpdateClassParams params) async {
    final response = await apiClient.put('/classes/$classId', data: params.toJson());

    if (response.statusCode == 200) {
      return SchoolClassModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al actualizar clase',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> deleteClass(String classId) async {
    final response = await apiClient.delete('/classes/$classId');

    if (response.statusCode != 204) {
      throw ServerException(
        message: 'Error al eliminar clase',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<AssignmentModel> createAssignment(String classId, CreateAssignmentParams params) async {
    final response = await apiClient.post(
      '/classes/$classId/assignments',
      data: params.toJson(),
    );

    if (response.statusCode == 201) {
      return AssignmentModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al crear tarea',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<StudentProgressModel>> getClassStudents(String classId) async {
    final response = await apiClient.get('/classes/$classId/students');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => StudentProgressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener estudiantes',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<EnrollmentModel> joinClass(JoinClassParams params) async {
    final response = await apiClient.post('/classes/join', data: params.toJson());

    if (response.statusCode == 201) {
      return EnrollmentModel.fromJson(response.data as Map<String, dynamic>);
    }

    String message = 'Error al unirse a la clase';
    if (response.statusCode == 404) {
      message = 'Clase no encontrada. Verifica el código.';
    } else if (response.statusCode == 409) {
      message = 'Ya estás inscrito en esta clase';
    }

    throw ServerException(message: message, statusCode: response.statusCode);
  }

  @override
  Future<void> leaveClass(String classId) async {
    final response = await apiClient.delete('/classes/$classId/leave');

    if (response.statusCode != 204) {
      throw ServerException(
        message: 'Error al salir de la clase',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<ClassListModel> getEnrolledClasses() async {
    final response = await apiClient.get('/classes/enrolled');

    if (response.statusCode == 200) {
      return ClassListModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: 'Error al obtener clases',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<SchoolClassModel> getClassById(String classId) async {
    final response = await apiClient.get('/classes/$classId');

    if (response.statusCode == 200) {
      return SchoolClassModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: 'Clase no encontrada',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<AssignmentModel>> getClassAssignments(String classId) async {
    final response = await apiClient.get('/classes/$classId/assignments');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AssignmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ServerException(
      message: 'Error al obtener tareas',
      statusCode: response.statusCode,
    );
  }
}
