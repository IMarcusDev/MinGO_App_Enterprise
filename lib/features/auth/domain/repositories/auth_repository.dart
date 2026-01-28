import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Parámetros para login
class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });
}

/// Parámetros para registro - ALINEADOS CON API
/// API espera: email, password, name, role
class RegisterParams {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        'role': role.value,
      };
}

/// Parámetros para reset de contraseña
class ResetPasswordParams {
  final String token;
  final String newPassword;

  const ResetPasswordParams({
    required this.token,
    required this.newPassword,
  });
}

/// Parámetros para actualizar perfil
class UpdateProfileParams {
  final String name;
  final String? phone;

  const UpdateProfileParams({
    required this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (phone != null) 'phone': phone,
      };
}

/// Parámetros para cambiar contraseña
class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}

/// Respuesta de autenticación
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

/// Respuesta de mensaje simple
class MessageResponse {
  final String message;
  final bool success;

  const MessageResponse({
    required this.message,
    required this.success,
  });
}

/// Repositorio de autenticación
abstract class AuthRepository {
  /// Registrar nuevo usuario
  Future<Either<Failure, AuthResponse>> register(RegisterParams params);

  /// Iniciar sesión
  Future<Either<Failure, AuthResponse>> login(LoginParams params);

  /// Cerrar sesión
  Future<Either<Failure, void>> logout();

  /// Obtener usuario actual
  Future<Either<Failure, User>> getCurrentUser();

  /// Verificar si hay sesión activa
  Future<Either<Failure, bool>> isLoggedIn();

  /// Verificar email con token
  Future<Either<Failure, MessageResponse>> verifyEmail(String token);

  /// Reenviar email de verificación
  Future<Either<Failure, MessageResponse>> resendVerification(String email);

  /// Solicitar reset de contraseña
  Future<Either<Failure, MessageResponse>> forgotPassword(String email);

  /// Resetear contraseña con token
  Future<Either<Failure, MessageResponse>> resetPassword(ResetPasswordParams params);

  /// Refrescar token
  Future<Either<Failure, AuthResponse>> refreshToken();

  /// Actualizar perfil de usuario
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params);

  /// Cambiar contraseña (usuario autenticado)
  Future<Either<Failure, MessageResponse>> changePassword(ChangePasswordParams params);

  /// Eliminar cuenta (requiere contraseña para confirmar)
  Future<Either<Failure, MessageResponse>> deleteAccount(String password);
}
