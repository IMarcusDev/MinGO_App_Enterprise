import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Eventos del AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Verificar estado de autenticación
class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

/// Iniciar sesión
class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Registrar usuario
class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  const AuthRegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

/// Cerrar sesión
class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

/// Verificar email
class AuthVerifyEmailEvent extends AuthEvent {
  final String token;

  const AuthVerifyEmailEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

/// Reenviar verificación
class AuthResendVerificationEvent extends AuthEvent {
  final String email;

  const AuthResendVerificationEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Olvidé mi contraseña
class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Resetear contraseña
class AuthResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;

  const AuthResetPasswordEvent({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}

/// Limpiar error
class AuthClearErrorEvent extends AuthEvent {
  const AuthClearErrorEvent();
}

/// Actualizar perfil
class AuthUpdateProfileEvent extends AuthEvent {
  final String name;
  final String? phone;

  const AuthUpdateProfileEvent({
    required this.name,
    this.phone,
  });

  @override
  List<Object?> get props => [name, phone];
}

/// Cambiar contraseña (autenticado)
class AuthChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Eliminar cuenta
class AuthDeleteAccountEvent extends AuthEvent {
  final String password;

  const AuthDeleteAccountEvent({required this.password});

  @override
  List<Object?> get props => [password];
}
