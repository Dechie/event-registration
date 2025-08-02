// lib/features/auth/data/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_reg/features/auth/data/models/login/login_request.dart';
import 'package:event_reg/features/auth/data/models/login/login_response.dart';
import 'package:event_reg/features/auth/data/models/otp/otp_verification_request.dart';
import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:event_reg/features/auth/data/models/registration/user_registration_request.dart';
import 'package:event_reg/features/auth/data/models/registration/user_registration_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
    required String userType,
    bool rememberMe = false,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserRegistrationResponse>> registerUser({
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<Either<Failure, String>> resendOTP(String email);
  Future updateProfile({
    required String fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? nationality,
    required String phoneNumber,
    String? region,
    String? city,
    String? woreda,
    String? idNumber,
    required String occupation,
    required String organization,
    String? department,
    required String industry,
    int? yearsOfExperience,
    String? photoPath,
  });

  Future<Either<Failure, String>> verifyOTP({
    required String email,
    required String otp,
    required String? otpToken,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final isTokenValid = await localDataSource.isTokenValid();
      // do refresh token logi (left for future)

      final cachedData = await localDataSource.getCachedUserData();
      if (cachedData != null) {
        return Right(cachedData.user);
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final user = await getCurrentUser();
      return user.fold(
        (failure) => const Right(false),
        (user) => Right(user != null),
      );
    } catch (e) {
      return const Right(false);
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
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      final loginRequest = LoginRequest(
        email: email,
        password: password,
        userType: userType,
        rememberMe: rememberMe,
      );

      final loginResponse = await remoteDatasource.login(loginRequest);

      await localDataSource.cacheUserData(loginResponse);
      await localDataSource.setRememberMe(rememberMe);

      return Right(loginResponse);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUserData();
      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.logout();
        } catch (e) {}
      }
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserRegistrationResponse>> registerUser({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internect connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      final registrationRequest = UserRegistrationRequest(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final response = await remoteDatasource.registerUser(registrationRequest);
      return Right(response);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, String>> resendOTP(String email) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }
      final message = await remoteDatasource.resendOTP(email);
      return Right(message);
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future updateProfile({
    required String fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? nationality,
    required String phoneNumber,
    String? region,
    String? city,
    String? woreda,
    String? idNumber,
    required String occupation,
    required String organization,
    String? department,
    required String industry,
    int? yearsOfExperience,
    String? photoPath,
  }) async {}

  @override
  Future<Either<Failure, String>> verifyOTP({
    required String email,
    required String otp,
    required String? otpToken,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      final otpRequest = OtpVerificationRequest(
        email: email,
        otp: otp,
        otpToken: otpToken,
      );

      final message = await remoteDatasource.verifyOTP(otpRequest);
      return Right(message);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
