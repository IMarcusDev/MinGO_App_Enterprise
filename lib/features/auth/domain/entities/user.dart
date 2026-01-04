import 'package:equatable/equatable.dart';

/// Roles de usuario - ALINEADOS CON API
enum UserRole {
  padre('PADRE'),
  docente('DOCENTE'),
  admin('ADMIN');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value.toUpperCase(),
      orElse: () => UserRole.padre,
    );
  }
}

/// Entidad User del dominio
/// 
/// ALINEADA con UserResponseDto de la API:
/// - id, email, name, role, profilePicUrl, isActive, emailVerified, createdAt
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? profilePicUrl;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profilePicUrl,
    required this.isActive,
    required this.emailVerified,
    required this.createdAt,
  });

  /// Usuario vacío para estado inicial
  static final empty = User(
    id: '',
    email: '',
    name: '',
    role: UserRole.padre,
    isActive: false,
    emailVerified: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
  
  bool get isPadre => role == UserRole.padre;
  bool get isDocente => role == UserRole.docente;
  bool get isAdmin => role == UserRole.admin;

  /// Crear copia con cambios
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? profilePicUrl,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        profilePicUrl,
        isActive,
        emailVerified,
        createdAt,
      ];
}
