import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/profile_remote_datasource.dart';
import 'package:event_reg/features/auth/data/models/login/login_request.dart';
import 'package:event_reg/features/auth/data/models/login/login_response.dart';
import 'package:event_reg/features/auth/data/models/otp/otp_verification_request.dart';
import 'package:event_reg/features/auth/data/models/registration/user_registration_request.dart';
import 'package:event_reg/features/auth/data/models/registration/user_registration_response.dart';
import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:flutter/material.dart' show debugPrint;

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> createProfile({
    required String fullName,
    String? gender,
    required String phoneNumber,
    required String occupation,
    required String organization,
    String? photoPath,
  });
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
    required String role,
    bool rememberMe = false,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserRegistrationResponse>> registerUser({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  });
  Future<Either<Failure, String>> resendOTP(String email);
  Future<Either<Failure, User>> updateProfile({
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
  final AuthLocalDatasource localDataSource;
  final ProfileRemoteDatasource profileRemoteDatasource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
    required this.profileRemoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> createProfile({
    required String fullName,
    String? gender,
    required String phoneNumber,
    required String occupation,
    required String organization,
    String? photoPath,
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

      debugPrint("🔐 Attempting create profile");
      // Get token from cached user data
      final cachedData = await localDataSource.getCachedUserData();
      if (cachedData?.token == null) {
        debugPrint("at auth repository: token is null");

        return const Left(
          AuthenticationFailure(
            message: "Authentication required",
            code: "TOKEN_REQUIRED",
          ),
        );
      }

      final profileData = {
        'full_name': fullName,
        'phone': phoneNumber,
        'occupation': occupation,
        'organization': organization,
        if (gender != null) 'gender': gender,
        if (photoPath != null) 'photoPath': photoPath,
      };

      final result = await profileRemoteDatasource.createProfile(
        token: cachedData!.token,
        profileData: profileData,
      );

      debugPrint('✅ create profile successful');

      return Right(result);
    } on NetworkException catch (e) {
      debugPrint('❌ Network error during create profile: ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint('❌ Authentication error during create profile: ${e.message}');

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint('❌ Validation error during create profile: ${e.message}');

      if (e.code == "PROFILE_ALREADY_EXISTS") {
        debugPrint('❌ Profile already exists.');

        return Left(
          ValidationFailure(
            message: "Profile already exists",
            code: "PROFILE_ALREADY_EXISTS",
          ),
        );
      }

      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error during Profile create: ${e.message}');

      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during profile create: $e');

      return const Left(UnknownFailure());
    }
  }

  // Update the getCurrentUser method:
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Get cached user data
      final cachedData = await localDataSource.getCachedUserData();
      if (cachedData != null) {
        debugPrint('✅ Found cached user data for: ${cachedData.user.email}');

        return Right(cachedData.user);
      }

      debugPrint('⚠️ No cached user data found');

      return const Right(null);
    } on CacheException catch (e) {
      debugPrint('❌ Cache error getting current user: ${e.message}');

      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error getting current user: $e');

      return const Left(UnknownFailure());
    }
  }

  // Update the isAuthenticated method:
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = await localDataSource.isAuthenticated();
      debugPrint('🔍 User authenticated: $isAuth');

      return Right(isAuth);
    } catch (e) {
      debugPrint('❌ Error checking authentication: $e');

      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
    required String role,
    bool rememberMe = false,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      debugPrint('🔐 Attempting login for: $email with role: $role');

      final loginRequest = LoginRequest(
        email: email,
        password: password,
        role: role,
      );

      // Call the remote datasource
      final loginResponse = await remoteDatasource.login(loginRequest);

      debugPrint('✅ Login successful, caching user data...');
      if (loginResponse.user.role == "no-role") {
        LoginResponse loginResponseCopy = loginResponse.copyWithForceUserRole(
          role: role,
        );
        await localDataSource.cacheUserData(loginResponseCopy);

        // Cache the user data locally
        debugPrint('✅ User data cached successfully');

        return Right(loginResponseCopy);
      } else {
        await localDataSource.cacheUserData(loginResponse);

        // Cache the user data locally
        debugPrint('✅ User data cached successfully');

        return Right(loginResponse);
      }
    } on NetworkException catch (e) {
      debugPrint('❌ Network error during login: ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint('❌ Authentication error during login: ${e.message}');

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint('❌ Validation error during login: ${e.message}');

      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error during login: ${e.message}');

      return Left(ServerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      debugPrint('❌ Cache error during login: ${e.message}');
      // Login was successful but caching failed - still return success
      // but maybe log this for monitoring

      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during login: $e');

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
        } catch (e) {
          // todo: implement sth here
        }
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
    required String role,
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

      final registrationRequest = UserRegistrationRequest(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
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
  Future<Either<Failure, User>> updateProfile({
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

      // Get token from cached user data
      final cachedData = await localDataSource.getCachedUserData();
      if (cachedData?.token == null) {
        return const Left(
          AuthenticationFailure(
            message: "Authentication required",
            code: "TOKEN_REQUIRED",
          ),
        );
      }

      final profileData = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'occupation': occupation,
        'organization': organization,
        'industry': industry,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
        if (nationality != null) 'nationality': nationality,
        if (region != null) 'region': region,
        if (city != null) 'city': city,
        if (woreda != null) 'woreda': woreda,
        if (idNumber != null) 'idNumber': idNumber,
        if (department != null) 'department': department,
        if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
        if (photoPath != null) 'photoPath': photoPath,
      };

      final updatedUser = await profileRemoteDatasource.updateProfile(
        token: cachedData!.token,
        profileData: profileData,
      );

      // Update cached user data
      final updatedLoginResponse = LoginResponse(
        id: updatedUser.id,
        user: updatedUser,
        token: cachedData.token,
        message: "Profile updated successfully",
      );
      await localDataSource.cacheUserData(updatedLoginResponse);

      return Right(updatedUser);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
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
