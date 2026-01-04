import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/children_repository.dart';
import '../models/child_model.dart';

/// Datasource remoto para hijos
abstract class ChildrenRemoteDataSource {
  Future<ChildModel> createChild(CreateChildParams params);
  Future<ChildListModel> getChildren();
  Future<ChildModel> getChildById(String id);
  Future<ChildModel> updateChild(String id, UpdateChildParams params);
  Future<void> deleteChild(String id);
}

class ChildrenRemoteDataSourceImpl implements ChildrenRemoteDataSource {
  final ApiClient apiClient;

  ChildrenRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ChildModel> createChild(CreateChildParams params) async {
    final response = await apiClient.post(
      '/children',
      data: params.toJson(),
    );

    if (response.statusCode == 201) {
      return ChildModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al crear hijo',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ChildListModel> getChildren() async {
    final response = await apiClient.get('/children');

    if (response.statusCode == 200) {
      return ChildListModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: 'Error al obtener hijos',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ChildModel> getChildById(String id) async {
    final response = await apiClient.get('/children/$id');

    if (response.statusCode == 200) {
      return ChildModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: 'Hijo no encontrado',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ChildModel> updateChild(String id, UpdateChildParams params) async {
    final response = await apiClient.put(
      '/children/$id',
      data: params.toJson(),
    );

    if (response.statusCode == 200) {
      return ChildModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al actualizar hijo',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> deleteChild(String id) async {
    final response = await apiClient.delete('/children/$id');

    if (response.statusCode != 204) {
      throw ServerException(
        message: 'Error al eliminar hijo',
        statusCode: response.statusCode,
      );
    }
  }
}
