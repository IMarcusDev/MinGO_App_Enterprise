import 'package:equatable/equatable.dart';

/// Clase base para todos los Failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Error del servidor', super.code});
  
  factory ServerFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ServerFailure(message: 'Solicitud inválida', code: '400');
      case 401:
        return const ServerFailure(message: 'No autorizado', code: '401');
      case 403:
        return const ServerFailure(message: 'Acceso denegado', code: '403');
      case 404:
        return const ServerFailure(message: 'No encontrado', code: '404');
      case 409:
        return const ServerFailure(message: 'Conflicto de datos', code: '409');
      case 422:
        return const ServerFailure(message: 'Datos inválidos', code: '422');
      case 500:
        return const ServerFailure(message: 'Error interno del servidor', code: '500');
      default:
        return ServerFailure(message: 'Error del servidor ($statusCode)', code: statusCode.toString());
    }
  }
}

/// Error de red/conexión
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Sin conexión a internet', super.code = 'NETWORK_ERROR'});
}

/// Error de caché
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error de caché local', super.code = 'CACHE_ERROR'});
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Error de autenticación', super.code});
  
  factory AuthFailure.invalidCredentials() => const AuthFailure(
    message: 'Email o contraseña incorrectos',
    code: 'INVALID_CREDENTIALS',
  );
  
  factory AuthFailure.sessionExpired() => const AuthFailure(
    message: 'Tu sesión ha expirado. Inicia sesión nuevamente.',
    code: 'SESSION_EXPIRED',
  );
  
  factory AuthFailure.emailNotVerified() => const AuthFailure(
    message: 'Debes verificar tu email antes de continuar',
    code: 'EMAIL_NOT_VERIFIED',
  );
  
  factory AuthFailure.emailAlreadyExists() => const AuthFailure(
    message: 'Este email ya está registrado',
    code: 'EMAIL_EXISTS',
  );
  
  factory AuthFailure.invalidToken() => const AuthFailure(
    message: 'Token inválido o expirado',
    code: 'INVALID_TOKEN',
  );
  
  factory AuthFailure.weakPassword() => const AuthFailure(
    message: 'La contraseña es muy débil',
    code: 'WEAK_PASSWORD',
  );
}

/// Error de validación
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  
  const ValidationFailure({
    super.message = 'Datos inválidos',
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Error de negocio/dominio
class BusinessFailure extends Failure {
  const BusinessFailure({required super.message, super.code});
}

/// Excepciones personalizadas
class ServerException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $code, status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Sin conexión a internet'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Error de caché'});

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}
