import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkAuthStatusUseCase,
    required this.verifyEmailUseCase,
    required this.resendVerificationUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.refreshTokenUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
  }) : super(const AuthInitialState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthVerifyEmailEvent>(_onVerifyEmail);
    on<AuthResendVerificationEvent>(_onResendVerification);
    on<AuthForgotPasswordEvent>(_onForgotPassword);
    on<AuthResetPasswordEvent>(_onResetPassword);
    on<AuthClearErrorEvent>(_onClearError);
    on<AuthUpdateProfileEvent>(_onUpdateProfile);
    on<AuthChangePasswordEvent>(_onChangePassword);
    on<AuthDeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Verificando sesión...'));

    final isLoggedIn = await checkAuthStatusUseCase();
    
    await isLoggedIn.fold(
      (failure) async => emit(const AuthUnauthenticatedState()),
      (loggedIn) async {
        if (loggedIn) {
          final userResult = await getCurrentUserUseCase();
          userResult.fold(
            (failure) => emit(const AuthUnauthenticatedState()),
            (user) {
              if (!user.emailVerified) {
                emit(AuthEmailVerificationPendingState(
                  email: user.email,
                  user: user,
                ));
              } else {
                emit(AuthAuthenticatedState(user: user));
              }
            },
          );
        } else {
          emit(const AuthUnauthenticatedState());
        }
      },
    );
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Iniciando sesión...'));

    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (authResponse) {
        final user = authResponse.user;
        if (!user.emailVerified) {
          emit(AuthEmailVerificationPendingState(
            email: user.email,
            user: user,
          ));
        } else {
          emit(AuthAuthenticatedState(user: user));
        }
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Creando cuenta...'));

    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      name: event.name,
      role: event.role,
    ));

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (authResponse) {
        // Después del registro, email pendiente de verificar
        emit(AuthEmailVerificationPendingState(
          email: authResponse.user.email,
          user: authResponse.user,
        ));
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Cerrando sesión...'));

    await logoutUseCase();
    emit(const AuthUnauthenticatedState());
  }

  Future<void> _onVerifyEmail(
    AuthVerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Verificando email...'));

    final result = await verifyEmailUseCase(event.token);

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (response) {
        emit(AuthEmailVerifiedState(message: response.message));
      },
    );
  }

  Future<void> _onResendVerification(
    AuthResendVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Enviando email...'));

    final result = await resendVerificationUseCase(event.email);

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (response) {
        emit(AuthVerificationResentState(message: response.message));
      },
    );
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Enviando email...'));

    final result = await forgotPasswordUseCase(event.email);

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (response) {
        emit(AuthPasswordResetEmailSentState(message: response.message));
      },
    );
  }

  Future<void> _onResetPassword(
    AuthResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Cambiando contraseña...'));

    final result = await resetPasswordUseCase(ResetPasswordParams(
      token: event.token,
      newPassword: event.newPassword,
    ));

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (response) {
        emit(AuthPasswordResetSuccessState(message: response.message));
      },
    );
  }

  void _onClearError(
    AuthClearErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticatedState());
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Actualizando perfil...'));

    final result = await updateProfileUseCase(UpdateProfileParams(
      name: event.name,
      phone: event.phone,
    ));

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (user) {
        emit(AuthProfileUpdatedState(
          user: user,
          message: 'Perfil actualizado correctamente',
        ));
      },
    );
  }

  Future<void> _onChangePassword(
    AuthChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Cambiando contraseña...'));

    final result = await changePasswordUseCase(ChangePasswordParams(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    ));

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (response) {
        emit(AuthPasswordChangedState(message: response.message));
      },
    );
  }

  Future<void> _onDeleteAccount(
    AuthDeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Eliminando cuenta...'));

    final result = await deleteAccountUseCase(event.password);

    result.fold(
      (failure) => emit(AuthErrorState(
        message: failure.message,
        code: failure.code,
      )),
      (response) {
        emit(AuthAccountDeletedState(message: response.message));
      },
    );
  }
}
