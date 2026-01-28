import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthResponse>> register(RegisterParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.register(params);
      await localDataSource.cacheUser(result.user);
      
      return Right(AuthResponse(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user.toEntity(),
      ));
    } on AuthException catch (e) {
      if (e.code == 'EMAIL_EXISTS') {
        return Left(AuthFailure.emailAlreadyExists());
      }
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login(LoginParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.login(params);
      await localDataSource.cacheUser(result.user);
      
      return Right(AuthResponse(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user.toEntity(),
      ));
    } on AuthException {
      return Left(AuthFailure.invalidCredentials());
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        return Left(AuthFailure.invalidCredentials());
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearCache();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final cachedUser = await localDataSource.getCachedUser();
    
    if (!await networkInfo.isConnected) {
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on AuthException {
      return Left(AuthFailure.sessionExpired());
    } on ServerException catch (e) {
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final hasSession = await localDataSource.hasValidSession();
      if (!hasSession) return const Right(false);
      
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser != null);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, MessageResponse>> verifyEmail(String token) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.verifyEmail(token);
      return Right(MessageResponse(
        message: result.message,
        success: result.success,
      ));
    } on ServerException {
      return Left(AuthFailure.invalidToken());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageResponse>> resendVerification(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.resendVerification(email);
      return Right(MessageResponse(
        message: result.message,
        success: result.success,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageResponse>> forgotPassword(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.forgotPassword(email);
      return Right(MessageResponse(
        message: result.message,
        success: result.success,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageResponse>> resetPassword(ResetPasswordParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.resetPassword(
        params.token,
        params.newPassword,
      );
      return Right(MessageResponse(
        message: result.message,
        success: result.success,
      ));
    } on ServerException {
      return Left(AuthFailure.invalidToken());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(user);

      return Right(AuthResponse(
        accessToken: '',
        refreshToken: '',
        user: user.toEntity(),
      ));
    } on AuthException {
      await localDataSource.clearCache();
      return Left(AuthFailure.sessionExpired());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.updateProfile(params);
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageResponse>> changePassword(ChangePasswordParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.changePassword(params);
      return Right(MessageResponse(
        message: result.message,
        success: result.success,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageResponse>> deleteAccount(String password) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.deleteAccount(password);
      // Limpiar caché local después de eliminar la cuenta
      await localDataSource.clearCache();
      return Right(MessageResponse(
        message: result.message,
        success: result.success,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        return const Left(AuthFailure(
          message: 'Contraseña incorrecta',
          code: 'INVALID_PASSWORD',
        ));
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
