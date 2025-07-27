// lib/features/auth/data/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/features/auth/data/models/login_response.dart';
import 'package:event_reg/features/auth/data/models/login_request.dart';
import 'package:event_reg/features/auth/data/models/admin.dart';
import 'package:event_reg/features/auth/data/models/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
    required String userType,
    bool rememberMe = false,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, String>> forgotPassword(String email);

  Future<Either<Failure, String>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, LoginResponse>> refreshToken();

  Future<Either<Failure, bool>> isLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
    required String userType,
    bool rememberMe = false,
  }) async {
    try {
      final loginRequest = LoginRequest(
        email: email,
        password: password,
        userType: userType,
        rememberMe: rememberMe,
      );

      final loginResponse = await remoteDataSource.login(loginRequest);

      // Cache user data locally
      await localDataSource.cacheUserData(loginResponse);
      if (rememberMe) {
        await localDataSource.setRememberMe(true);
      }

      return Right(loginResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } on CacheException catch (e) {
      // Even if caching fails, login was successful
      return Left(CacheFailure(
        message: 'Login successful but failed to save session: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'An unexpected error occurred during login',
        code: 'LOGIN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Try to logout from server (optional - can fail silently)
      try {
        await remoteDataSource.logout();
      } catch (e) {
        // Server logout failure shouldn't prevent local logout
        print('Server logout failed: $e');
      }

      // Always clear local data
      await localDataSource.clearUserData();
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to logout completely',
        code: 'LOGOUT_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUserData();
      
      if (cachedUser != null) {
        // Check if token is still valid
        final isTokenValid = await localDataSource.isTokenValid();
        
        if (isTokenValid) {
          return Right(cachedUser.user);
        } else {
          // Try to refresh token
          final refreshResult = await refreshToken();
          return refreshResult.fold(
            (failure) => const Right(null), // Token refresh failed
            (loginResponse) => Right(loginResponse.user),
          );
        }
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to get current user',
        code: 'GET_USER_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final message = await remoteDataSource.forgotPassword(email);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to send password reset email',
        code: 'FORGOT_PASSWORD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final message = await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to reset password',
        code: 'RESET_PASSWORD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, LoginResponse>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      
      if (refreshToken == null) {
        return Left(AuthFailure(
          message: 'No refresh token available',
          code: 'NO_REFRESH_TOKEN',
        ));
      }

      final loginResponse = await remoteDataSource.refreshToken(refreshToken);
      
      // Update cached data
      await localDataSource.cacheUserData(loginResponse);
      
      return Right(loginResponse);
    } on ServerException catch (e) {
      // Clear invalid tokens
      await localDataSource.clearUserData();
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to refresh authentication token',
        code: 'REFRESH_TOKEN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final cachedUser = await localDataSource.getCachedUserData();
      
      if (cachedUser == null) {
        return const Right(false);
      }

      final isTokenValid = await localDataSource.isTokenValid();
      return Right(isTokenValid);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to check login status',
        code: 'LOGIN_CHECK_ERROR',
      ));
    }
  }
}