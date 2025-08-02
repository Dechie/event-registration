// lib/features/auth/data/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_reg/features/auth/data/models/login/login_request.dart';
import 'package:event_reg/features/auth/data/models/login/login_response.dart';
import 'package:event_reg/features/auth/data/models/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
    required String userType,
    bool rememberMe = false,
  });

  Future<Either<Failure, void>> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

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
          // //final refreshResult = await refreshToken();
          // return refreshResult.fold(
          //   (failure) => const Right(null), // Token refresh failed
          //   (loginResponse) => Right(loginResponse.user),
          // );
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Failed to get current user',
          code: 'GET_USER_ERROR',
        ),
      );
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
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Failed to check login status',
          code: 'LOGIN_CHECK_ERROR',
        ),
      );
    }
  }

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
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      // Even if caching fails, login was successful
      return Left(
        CacheFailure(
          message: 'Login successful but failed to save session: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'An unexpected error occurred during login',
          code: 'LOGIN_ERROR',
        ),
      );
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
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Failed to logout completely',
          code: 'LOGOUT_ERROR',
        ),
      );
    }
  }
}
