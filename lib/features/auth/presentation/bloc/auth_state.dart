import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Estados del AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// Cargando
class AuthLoadingState extends AuthState {
  final String? message;

  const AuthLoadingState({this.message});

  @override
  List<Object?> get props => [message];
}

/// Usuario autenticado
class AuthAuthenticatedState extends AuthState {
  final User user;

  const AuthAuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

/// No autenticado
class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

/// Email pendiente de verificación
class AuthEmailVerificationPendingState extends AuthState {
  final String email;
  final User? user;

  const AuthEmailVerificationPendingState({
    required this.email,
    this.user,
  });

  @override
  List<Object?> get props => [email, user];
}

/// Email verificado exitosamente
class AuthEmailVerifiedState extends AuthState {
  final String message;

  const AuthEmailVerifiedState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Verificación reenviada
class AuthVerificationResentState extends AuthState {
  final String message;

  const AuthVerificationResentState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Email de reset enviado
class AuthPasswordResetEmailSentState extends AuthState {
  final String message;

  const AuthPasswordResetEmailSentState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Contraseña reseteada
class AuthPasswordResetSuccessState extends AuthState {
  final String message;

  const AuthPasswordResetSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error
class AuthErrorState extends AuthState {
  final String message;
  final String? code;

  const AuthErrorState({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
