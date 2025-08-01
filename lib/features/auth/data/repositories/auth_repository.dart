// lib/features/auth/data/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_reg/features/auth/data/models/login_request.dart';
import 'package:event_reg/features/auth/data/models/login_response.dart';
import 'package:event_reg/features/auth/data/models/otp_verification_request.dart';
import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:event_reg/features/auth/data/models/user_registration_request.dart';
import 'package:event_reg/features/auth/data/models/user_registration_response.dart';

// abstract class AuthRepository {
//   Future<Either<Failure, String>> forgotPassword(String email);

//   Future<Either<Failure, User?>> getCurrentUser();
//   Future<Either<Failure, bool>> isAuthenticated();
//   Future<Either<Failure, LoginResponse>> login({
//     required String email,
//     required String password,
//     required String userType,
//     bool rememberMe = false,
//   });
//   Future<Either<Failure, void>> logout();
//   Future<Either<Failure, LoginResponse>> refreshToken();
//   Future<Either<Failure, UserRegistrationResponse>> registerUser({
//     required String email,
//     required String password,
//     required String passwordConfirmation,
//   });

//   Future resendOTP(String email) async {}

//   Future<Either<Failure, String>> resetPassword({
//     required String token,
//     required String newPassword,
//   });

//   Future verifyOTP({
//     required String email,
//     required String otp,
//     String? otpToken,
//   }) async {}
// }

// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemoteDataSource remoteDataSource;
//   final AuthLocalDataSource localDataSource;
//   final NetworkInfo networkInfo;

//   AuthRepositoryImpl({
//     required this.remoteDataSource,
//     required this.localDataSource,
//     required this.networkInfo,
//   });

//   @override
//   Future<Either<Failure, String>> forgotPassword(String email) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: 'No internet connection',
//             code: 'NETWORK_ERROR',
//           ),
//         );
//       }

//       final message = await remoteDataSource.forgotPassword(email);
//       return Right(message);
//     } on NetworkException catch (e) {
//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on ServerException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future<Either<Failure, User?>> getCurrentUser() async {
//     try {
//       // Check if token is still valid
//       final isTokenValid = await localDataSource.isTokenValid();

//       if (!isTokenValid) {
//         // Try to refresh token if available
//         final refreshResult = await refreshToken();
//         return refreshResult.fold(
//           (failure) => const Right(null), // No valid user
//           (loginResponse) => Right(loginResponse.user),
//         );
//       }

//       // Get cached user data
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
//       // Check network connectivity
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: 'No internet connection',
//             code: 'NETWORK_ERROR',
//           ),
//         );
//       }

//       // Create login request
//       final loginRequest = LoginRequest(
//         email: email,
//         password: password,
//         userType: userType,
//         rememberMe: rememberMe,
//       );

//       // Perform remote login
//       final loginResponse = await remoteDataSource.login(loginRequest);

//       // Cache user data locally
//       await localDataSource.cacheUserData(loginResponse);
//       await localDataSource.setRememberMe(rememberMe);

//       return Right(loginResponse);
//     } on NetworkException catch (e) {
//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on AuthenticationException catch (e) {
//       return Left(AuthenticationFailure(message: e.message, code: e.code));
//     } on ValidationException catch (e) {
//       return Left(
//         ValidationFailure(message: e.message, code: e.code, errors: e.errors),
//       );
//     } on ServerException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } on CacheException catch (e) {
//       // Login succeeded but caching failed - still return success
//       return Right(
//         await remoteDataSource.login(
//           LoginRequest(
//             email: email,
//             password: password,
//             userType: userType,
//             rememberMe: rememberMe,
//           ),
//         ),
//       );
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future<Either<Failure, void>> logout() async {
//     try {
//       // Always clear local data first
//       await localDataSource.clearUserData();

//       // Try to logout from server (can fail silently)
//       if (await networkInfo.isConnected) {
//         try {
//           await remoteDataSource.logout();
//         } catch (e) {
//           // Server logout can fail - we still consider local logout successful
//         }
//       }

//       return const Right(null);
//     } on CacheException catch (e) {
//       return Left(CacheFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future<Either<Failure, LoginResponse>> refreshToken() async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: 'No internet connection',
//             code: 'NETWORK_ERROR',
//           ),
//         );
//       }

//       final refreshToken = await localDataSource.getRefreshToken();

//       if (refreshToken == null) {
//         return const Left(
//           AuthenticationFailure(
//             message: 'No refresh token available',
//             code: 'NO_REFRESH_TOKEN',
//           ),
//         );
//       }

//       final loginResponse = await remoteDataSource.refreshToken(refreshToken);

//       // Update cached data
//       await localDataSource.cacheUserData(loginResponse);

//       return Right(loginResponse);
//     } on NetworkException catch (e) {
//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on AuthenticationException catch (e) {
//       // Clear invalid tokens
//       await localDataSource.clearUserData();
//       return Left(AuthenticationFailure(message: e.message, code: e.code));
//     } on ServerException catch (e) {
//       if (e.code == 'REFRESH_TOKEN_EXPIRED') {
//         await localDataSource.clearUserData();
//       }
//       return Left(ServerFailure(message: e.message, code: e.code));
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
//     return Right(
//       UserRegistrationResponse(
//         message: "message",
//         userId: "userId",
//         email: email,
//         otpSent: false,
//         otpToken: "",
//       ),
//     );
//   }

//   // Future registerUser({required String email, required String password, required String passwordConfirmation}) {
//   //   // TODO: implement registerUser
//   //   throw UnimplementedError();
//   // }

//   @override
//   Future resendOTP(String email) {
//     // TODO: implement resendOTP
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either<Failure, String>> resetPassword({
//     required String token,
//     required String newPassword,
//   }) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message: 'No internet connection',
//             code: 'NETWORK_ERROR',
//           ),
//         );
//       }

//       final message = await remoteDataSource.resetPassword(
//         token: token,
//         newPassword: newPassword,
//       );
//       return Right(message);
//     } on NetworkException catch (e) {
//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on ServerException catch (e) {
//       return Left(ServerFailure(message: e.message, code: e.code));
//     } catch (e) {
//       return const Left(UnknownFailure());
//     }
//   }

//   @override
//   Future verifyOTP({
//     required String email,
//     required String otp,
//     String? otpToken,
//   }) {
//     // TODO: implement verifyOTP
//     throw UnimplementedError();
//   }
// }

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
