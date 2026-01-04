import '../../domain/entities/user.dart';

/// Modelo de usuario para serialización JSON
/// 
/// ALINEADO con la respuesta de la API:
/// {
///   "id": "uuid",
///   "email": "email@example.com",
///   "name": "Nombre",
///   "role": "PADRE",
///   "profilePicUrl": "url",
///   "isActive": true,
///   "emailVerified": false,
///   "createdAt": "2024-01-01T00:00:00.000Z"
/// }
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.profilePicUrl,
    required super.isActive,
    required super.emailVerified,
    required super.createdAt,
  });

  /// Crear desde JSON de la API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      profilePicUrl: json['profilePicUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.value,
      'profilePicUrl': profilePicUrl,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crear desde entidad User
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      profilePicUrl: user.profilePicUrl,
      isActive: user.isActive,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    );
  }

  /// Convertir a entidad User
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: role,
      profilePicUrl: profilePicUrl,
      isActive: isActive,
      emailVerified: emailVerified,
      createdAt: createdAt,
    );
  }
}

/// Modelo de respuesta de autenticación
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Modelo de respuesta de mensaje
class MessageResponseModel {
  final String message;
  final bool success;

  const MessageResponseModel({
    required this.message,
    required this.success,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      message: json['message'] as String,
      success: json['success'] as bool,
    );
  }
}
