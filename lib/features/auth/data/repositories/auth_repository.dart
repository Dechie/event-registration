// // lib/features/auth/data/repositories/auth_repository.dart
// import 'package:dartz/dartz.dart';
// import 'package:event_reg/core/error/exceptions.dart';
// import 'package:event_reg/core/error/failures.dart';
// import 'package:event_reg/core/network/network_info.dart';
// import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
// import 'package:event_reg/features/auth/data/datasource/auth_remote_datasource.dart';
// import 'package:event_reg/features/auth/data/models/login/login_request.dart';
// import 'package:event_reg/features/auth/data/models/login/login_response.dart';
// import 'package:event_reg/features/auth/data/models/otp/otp_verification_request.dart';
// import 'package:event_reg/features/auth/data/models/user.dart';
// import 'package:event_reg/features/auth/data/models/registration/user_registration_request.dart';
// import 'package:event_reg/features/auth/data/models/registration/user_registration_response.dart';

// abstract class AuthRepository {
//   Future<Either<Failure, User?>> getCurrentUser();
//   Future<Either<Failure, bool>> isAuthenticated();
//   Future<Either<Failure, LoginResponse>> login({
//     required String email,
//     required String password,
//     required String userType,
//     bool rememberMe = false,
//   });
//   Future<Either<Failure, void>> logout();
//   Future<Either<Failure, UserRegistrationResponse>> registerUser({
//     required String email,
//     required String password,
//     required String passwordConfirmation,
//   });
//   Future<Either<Failure, String>> resendOTP(String email);
//   Future updateProfile({
//     required String fullName,
//     String? gender,
//     DateTime? dateOfBirth,
//     String? nationality,
//     required String phoneNumber,
//     String? region,
//     String? city,
//     String? woreda,
//     String? idNumber,
//     required String occupation,
//     required String organization,
//     String? department,
//     required String industry,
//     int? yearsOfExperience,
//     String? photoPath,
//   });

//   Future<Either<Failure, String>> verifyOTP({
//     required String email,
//     required String otp,
//     required String? otpToken,
//   });
// }

// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemoteDatasource remoteDatasource;
//   final AuthLocalDataSource localDataSource;
//   final NetworkInfo networkInfo;

//   AuthRepositoryImpl({
//     required this.localDataSource,
//     required this.remoteDatasource,
//     required this.networkInfo,
//   });

//   @override
//   Future<Either<Failure, User?>> getCurrentUser() async {
//     try {
//       final isTokenValid = await localDataSource.isTokenValid();
//       // do refresh token logi (left for future)

//       final cachedData = await localDataSource.getCachedUserData();
//       if (cachedData != null) {
//         return Right(cachedData.user);
//       }
//       return const Right(null);
//     } on CacheException catch (e) {
//       return Left(CacheFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future<Either<Failure, bool>> isAuthenticated() async {
//     try {
//       final user = await getCurrentUser();
//       return user.fold(
//         (failure) => const Right(false),
//         (user) => Right(user != null),
//       );
//     } catch (e) {
//       return const Right(false);
//     }
//   }

//   @override
//   Future<Either<Failure, LoginResponse>> login({
//     required String email,
//     required String password,
//     required String userType,
//     bool rememberMe = false,
//   }) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: "No internet connection",
//             code: "NETWORK_ERROR",
//           ),
//         );
//       }

//       final loginRequest = LoginRequest(
//         email: email,
//         password: password,
//         userType: userType,
//         rememberMe: rememberMe,
//       );

//       final loginResponse = await remoteDatasource.login(loginRequest);

//       await localDataSource.cacheUserData(loginResponse);
//       await localDataSource.setRememberMe(rememberMe);

//       return Right(loginResponse);
//     } on NetworkException catch (e) {
//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on AuthenticationException catch (e) {
//       return Left(AuthorizationFailure(message: e.message, code: e.code));
//     } on ValidationException catch (e) {
//       return Left(
//         ValidationFailure(message: e.message, code: e.code, errors: e.errors),
//       );
//     } on ServerException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future<Either<Failure, void>> logout() async {
//     try {
//       await localDataSource.clearUserData();
//       if (await networkInfo.isConnected) {
//         try {
//           await remoteDatasource.logout();
//         } catch (e) {}
//       }
//       return Right(null);
//     } on CacheException catch (e) {
//       return Left(CacheFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future<Either<Failure, UserRegistrationResponse>> registerUser({
//     required String email,
//     required String password,
//     required String passwordConfirmation,
//   }) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: "No internect connection",
//             code: "NETWORK_ERROR",
//           ),
//         );
//       }

//       final registrationRequest = UserRegistrationRequest(
//         email: email,
//         password: password,
//         passwordConfirmation: passwordConfirmation,
//       );

//       final response = await remoteDatasource.registerUser(registrationRequest);
//       return Right(response);
//     } on NetworkException catch (e) {
//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on ValidationException catch (e) {
//       return Left(
//         ValidationFailure(message: e.message, code: e.code, errors: e.errors),
//       );
//     } on ServerException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future<Either<Failure, String>> resendOTP(String email) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: "No internet connection",
//             code: "NETWORK_ERROR",
//           ),
//         );
//       }
//       final message = await remoteDatasource.resendOTP(email);
//       return Right(message);
//     } on NetworkException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } on ServerException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future updateProfile({
//     required String fullName,
//     String? gender,
//     DateTime? dateOfBirth,
//     String? nationality,
//     required String phoneNumber,
//     String? region,
//     String? city,
//     String? woreda,
//     String? idNumber,
//     required String occupation,
//     required String organization,
//     String? department,
//     required String industry,
//     int? yearsOfExperience,
//     String? photoPath,
//   }) async {}

//   @override
//   Future<Either<Failure, String>> verifyOTP({
//     required String email,
//     required String otp,
//     required String? otpToken,
//   }) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: "No internet connection",
//             code: "NETWORK_ERROR",
//           ),
//         );
//       }

//       final otpRequest = OtpVerificationRequest(
//         email: email,
//         otp: otp,
//         otpToken: otpToken,
//       );

//       final message = await remoteDatasource.verifyOTP(otpRequest);
//       return Right(message);
//     } on NetworkException catch (e) {
//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on ValidationException catch (e) {
//       return Left(
//         ValidationFailure(message: e.message, code: e.code, errors: e.errors),
//       );
//     } on ServerException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }
// }

// lib/features/auth/data/repositories/auth_repository.dart
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
  final AuthLocalDataSource localDataSource;
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

      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      if (e.code == "PROFILE_ALREADY_EXISTS") {
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
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final isTokenValid = await localDataSource.isTokenValid();
      // do refresh token logic (left for future)

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
            message: "No internet connection",
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
        user: updatedUser,
        token: cachedData.token,
        message: "Profile updated successfully",
        expiresAt: DateTime.now().add(Duration(days: 100)),
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
