import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Datasource remoto de autenticación
/// 
/// Se comunica con la API NestJS (NO con Supabase Auth directamente)
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register(RegisterParams params);
  Future<AuthResponseModel> login(LoginParams params);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<MessageResponseModel> verifyEmail(String token);
  Future<MessageResponseModel> resendVerification(String email);
  Future<MessageResponseModel> forgotPassword(String email);
  Future<MessageResponseModel> resetPassword(String token, String newPassword);
  Future<UserModel> updateProfile(UpdateProfileParams params);
  Future<MessageResponseModel> changePassword(ChangePasswordParams params);
  Future<MessageResponseModel> deleteAccount(String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> register(RegisterParams params) async {
    final response = await apiClient.post(
      ApiEndpoints.authRegister,
      data: params.toJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final authResponse = AuthResponseModel.fromJson(response.data);
      
      // Guardar tokens
      await apiClient.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      
      return authResponse;
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al registrar',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<AuthResponseModel> login(LoginParams params) async {
    final response = await apiClient.post(
      ApiEndpoints.authLogin,
      data: {
        'email': params.email,
        'password': params.password,
      },
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponseModel.fromJson(response.data);
      
      // Guardar tokens
      await apiClient.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      
      return authResponse;
    }

    throw ServerException(
      message: response.data['message'] ?? 'Credenciales inválidas',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> logout() async {
    await apiClient.clearTokens();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiEndpoints.authProfile);

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al obtener perfil',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiEndpoints.authRefresh,
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponseModel.fromJson(response.data);
      
      // Guardar nuevos tokens
      await apiClient.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      
      return authResponse;
    }

    throw ServerException(
      message: 'Token inválido',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<MessageResponseModel> verifyEmail(String token) async {
    final response = await apiClient.post(
      ApiEndpoints.authVerifyEmail,
      data: {'token': token},
    );

    if (response.statusCode == 200) {
      return MessageResponseModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Token inválido o expirado',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<MessageResponseModel> resendVerification(String email) async {
    final response = await apiClient.post(
      ApiEndpoints.authResendVerification,
      data: {'email': email},
    );

    if (response.statusCode == 200) {
      return MessageResponseModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al reenviar verificación',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<MessageResponseModel> forgotPassword(String email) async {
    final response = await apiClient.post(
      ApiEndpoints.authForgotPassword,
      data: {'email': email},
    );

    if (response.statusCode == 200) {
      return MessageResponseModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al enviar email',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<MessageResponseModel> resetPassword(String token, String newPassword) async {
    final response = await apiClient.post(
      ApiEndpoints.authResetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );

    if (response.statusCode == 200) {
      return MessageResponseModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Token inválido o expirado',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileParams params) async {
    final response = await apiClient.patch(
      ApiEndpoints.authProfile,
      data: params.toJson(),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al actualizar perfil',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<MessageResponseModel> changePassword(ChangePasswordParams params) async {
    final response = await apiClient.post(
      ApiEndpoints.authChangePassword,
      data: params.toJson(),
    );

    if (response.statusCode == 200) {
      return MessageResponseModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al cambiar contraseña',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<MessageResponseModel> deleteAccount(String password) async {
    final response = await apiClient.delete(
      ApiEndpoints.authDeleteAccount,
      data: {'password': password},
    );

    if (response.statusCode == 200) {
      // Limpiar tokens después de eliminar la cuenta
      await apiClient.clearTokens();
      return MessageResponseModel.fromJson(response.data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al eliminar la cuenta',
      statusCode: response.statusCode,
    );
  }
}
