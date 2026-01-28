import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use Case: Login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(LoginParams params) {
    return repository.login(params);
  }
}

/// Use Case: Register
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(RegisterParams params) {
    return repository.register(params);
  }
}

/// Use Case: Logout
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}

/// Use Case: Get Current User
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
}

/// Use Case: Check Auth Status
class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.isLoggedIn();
  }
}

/// Use Case: Verify Email
class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<Either<Failure, MessageResponse>> call(String token) {
    return repository.verifyEmail(token);
  }
}

/// Use Case: Resend Verification Email
class ResendVerificationUseCase {
  final AuthRepository repository;

  ResendVerificationUseCase(this.repository);

  Future<Either<Failure, MessageResponse>> call(String email) {
    return repository.resendVerification(email);
  }
}

/// Use Case: Forgot Password
class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, MessageResponse>> call(String email) {
    return repository.forgotPassword(email);
  }
}

/// Use Case: Reset Password
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, MessageResponse>> call(ResetPasswordParams params) {
    return repository.resetPassword(params);
  }
}

/// Use Case: Refresh Token
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call() {
    return repository.refreshToken();
  }
}

/// Use Case: Update Profile
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}

/// Use Case: Change Password
class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, MessageResponse>> call(ChangePasswordParams params) {
    return repository.changePassword(params);
  }
}

/// Use Case: Delete Account
class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, MessageResponse>> call(String password) {
    return repository.deleteAccount(password);
  }
}
