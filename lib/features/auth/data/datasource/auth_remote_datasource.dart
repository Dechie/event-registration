// // lib/features/auth/data/datasource/auth_remote_datasource.dart
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/auth/data/models/login_request.dart';
import 'package:event_reg/features/auth/data/models/login_response.dart';
import 'package:event_reg/features/auth/data/models/otp_verification_request.dart';
import 'package:event_reg/features/auth/data/models/user_registration_request.dart';
import 'package:event_reg/features/auth/data/models/user_registration_response.dart';
import 'package:flutter/material.dart' show debugPrint;

// abstract class AuthRemoteDataSource {
//   Future<String> forgotPassword(String email);
//   Future<LoginResponse> login(LoginRequest loginRequest);
//   Future<void> logout();
//   Future<LoginResponse> refreshToken(String refreshToken);
//   Future<UserRegistrationResponse> registerUser(
//     UserRegistrationRequest registrationRequest,
//   );
//   Future<String> resendOTP(String email);
//   Future<String> resetPassword({
//     required String token,
//     required String newPassword,
//   });
//   Future<String> verifyOTP(OTPVerificationRequest otpRequest);
// }

// class OTPVerificationRequest {}

// class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   final DioClient dioClient;

//   AuthRemoteDataSourceImpl({required this.dioClient});

//   @override
//   Future<String> forgotPassword(String email) async {
//     try {
//       final response = await dioClient.post(
//         '/auth/forgot-password',
//         data: {'email': email},
//       );

//       if (response.statusCode == 200) {
//         return response.data['message'] ??
//             'Password reset email sent successfully';
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to send reset email',
//           code: response.data['code'] ?? 'FORGOT_PASSWORD_FAILED',
//         );
//       }
//     } on DioException catch (e) {
//       if (e.type == DioExceptionType.connectionTimeout ||
//           e.type == DioExceptionType.receiveTimeout ||
//           e.type == DioExceptionType.sendTimeout) {
//         throw NetworkException(
//           message: 'Connection timeout. Please try again.',
//           code: 'TIMEOUT_ERROR',
//         );
//       } else if (e.type == DioExceptionType.connectionError) {
//         throw NetworkException(
//           message: 'No internet connection.',
//           code: 'NETWORK_ERROR',
//         );
//       } else if (e.response != null) {
//         final responseData = e.response!.data;
//         throw ServerException(
//           message: responseData['message'] ?? 'Failed to send reset email',
//           code: responseData['code'] ?? 'FORGOT_PASSWORD_ERROR',
//         );
//       } else {
//         throw ServerException(
//           message: 'Failed to send password reset email',
//           code: 'FORGOT_PASSWORD_ERROR',
//         );
//       }
//     }
//   }

//   @override
//   Future<LoginResponse> login(LoginRequest loginRequest) async {
//     try {
//       final response = await dioClient.post(
//         '/auth/login',
//         data: loginRequest.toJson(),
//       );

//       if (response.statusCode == 200) {
//         return LoginResponse.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Login failed',
//           code: response.data['code'] ?? 'LOGIN_FAILED',
//         );
//       }
//     } on DioException catch (e) {
//       if (e.type == DioExceptionType.connectionTimeout ||
//           e.type == DioExceptionType.receiveTimeout ||
//           e.type == DioExceptionType.sendTimeout) {
//         throw NetworkException(
//           message: 'Connection timeout. Please check your internet connection.',
//           code: 'TIMEOUT_ERROR',
//         );
//       } else if (e.type == DioExceptionType.connectionError) {
//         throw NetworkException(
//           message: 'No internet connection. Please check your network.',
//           code: 'NETWORK_ERROR',
//         );
//       } else if (e.response != null) {
//         final statusCode = e.response!.statusCode;
//         final responseData = e.response!.data;

//         switch (statusCode) {
//           case 401:
//             throw ServerException(
//               message: responseData['message'] ?? 'Invalid credentials',
//               code: 'INVALID_CREDENTIALS',
//             );
//           case 403:
//             throw ServerException(
//               message: responseData['message'] ?? 'Access denied',
//               code: 'ACCESS_DENIED',
//             );
//           case 404:
//             throw ServerException(
//               message: responseData['message'] ?? 'User not found',
//               code: 'USER_NOT_FOUND',
//             );
//           case 422:
//             throw ServerException(
//               message: responseData['message'] ?? 'Invalid input data',
//               code: 'VALIDATION_ERROR',
//             );
//           case 429:
//             throw ServerException(
//               message: responseData['message'] ?? 'Too many login attempts',
//               code: 'RATE_LIMIT_EXCEEDED',
//             );
//           default:
//             throw ServerException(
//               message: responseData['message'] ?? 'Server error occurred',
//               code: 'SERVER_ERROR',
//             );
//         }
//       } else {
//         throw ServerException(
//           message: 'Unknown server error occurred',
//           code: 'UNKNOWN_SERVER_ERROR',
//         );
//       }
//     } catch (e) {
//       if (e is ServerException || e is NetworkException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: 'An unexpected error occurred',
//         code: 'UNEXPECTED_ERROR',
//       );
//     }
//   }

//   @override
//   Future<void> logout() async {
//     try {
//       await dioClient.post('/auth/logout');
//     } on DioException catch (e) {
//       // Logout can fail silently on server side
//       print('Server logout failed: ${e.message}');
//     }
//   }

//   @override
//   Future<LoginResponse> refreshToken(String refreshToken) async {
//     try {
//       final response = await dioClient.post(
//         '/auth/refresh',
//         data: {'refresh_token': refreshToken},
//       );

//       if (response.statusCode == 200) {
//         return LoginResponse.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to refresh token',
//           code: 'TOKEN_REFRESH_FAILED',
//         );
//       }
//     } on DioException catch (e) {
//       if (e.response != null && e.response!.statusCode == 401) {
//         throw ServerException(
//           message: 'Refresh token expired',
//           code: 'REFRESH_TOKEN_EXPIRED',
//         );
//       }
//       throw ServerException(
//         message: 'Failed to refresh authentication',
//         code: 'TOKEN_REFRESH_ERROR',
//       );
//     }
//   }

//   @override
//   Future<String> resetPassword({
//     required String token,
//     required String newPassword,
//   }) async {
//     try {
//       final response = await dioClient.post(
//         '/auth/reset-password',
//         data: {'token': token, 'password': newPassword},
//       );

//       if (response.statusCode == 200) {
//         return response.data['message'] ?? 'Password reset successfully';
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to reset password',
//           code: response.data['code'] ?? 'RESET_PASSWORD_FAILED',
//         );
//       }
//     } on DioException catch (e) {
//       if (e.response != null && e.response!.statusCode == 400) {
//         throw ServerException(
//           message: 'Invalid or expired reset token',
//           code: 'INVALID_RESET_TOKEN',
//         );
//       }
//       throw ServerException(
//         message: 'Failed to reset password',
//         code: 'RESET_PASSWORD_ERROR',
//       );
//     }
//   }

//   @override
//   Future<UserRegistrationResponse> registerUser(
//     UserRegistrationRequest registrationRequest,
//   ) async {
//     UserRegistrationResponse res = UserRegistrationResponse(
//       message: "succes",
//       userId: "userId",
//       email: "email",
//       otpSent: true,
//     );

//     await Future.delayed(Duration(seconds: 2), () {});
//     return res;
//   }

//   @override
//   Future<String> resendOTP(String email) async {
//     await Future.delayed(Duration(seconds: 2));
//     return "otp code";
//   }

//   @override
//   Future<String> verifyOTP(OTPVerificationRequest otpRequest) async {
//     await Future.delayed(Duration(seconds: 2));
//     return "otp code";
//   }
// }
abstract class AuthRemoteDatasource {
  Future<LoginResponse> login(LoginRequest loginRequest);
  Future<void> logout();
  Future<UserRegistrationResponse> registerUser(
    UserRegistrationRequest registrationRequest,
  );
  Future<String> resendOTP(String email);
  Future<String> verifyOTP(OtpVerificationRequest otpRequest);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final DioClient dioClient;

  AuthRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final response = await dioClient.post(
        "/login",
        data: {"email": loginRequest.email, "password": loginRequest.password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // handle both nested data and direct respones formats
        final loginData = data["data"] ?? data;
        return LoginResponse.fromJson(loginData);
      } else {
        throw ServerException(
          message: response.data["message"] ?? "Login failed",
          code: response.data["code"] ?? "LOGIN_FAILED",
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, "LOGIN_ERROR");
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: "An Unexpected error occurred during login",
        code: "UNEXPECTED_LOGIN_ERROR",
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post("/logout");
    } on ApiError catch (e) {
      debugPrint("Server logout failed: ${e.message}");
    } catch (e) {
      debugPrint("Server logout failed: $e");
    }
  }

  @override
  Future<UserRegistrationResponse> registerUser(
    UserRegistrationRequest registrationRequest,
  ) async {
    try {
      final response = await dioClient.post(
        "/register",
        data: registrationRequest.toJson(),
      );

      if ([200, 201].contains(response.statusCode)) {
        // handle both nested data and direct respones formats
        final data = response.data;
        final responseData = data["data"] ?? data;

        return UserRegistrationResponse(
          message: responseData["message"] ?? "Registration Successfull",
          userId: responseData["user_id"] ?? responseData["id"] ?? "",
          email: responseData["email"] ?? registrationRequest.email,
          otpSent: responseData["otp_sent"] ?? true,
          otpToken: responseData["otp_token"],
        );
      } else {
        throw ServerException(
          message: response.data["message"] ?? "Registration Failed",
          code: response.data["code"] ?? 'REGISTRATION_FAILED',
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, 'REGISTRATION_ERROR');
    } catch (e) {
      if (e is ServerException || e is ValidationException) rethrow;
      throw ServerException(
        message: "Registration failed. Please try again",
        code: "REGISTRATOIN_ERROR",
      );
    }
  }

  @override
  Future<String> resendOTP(String email) async {
    try {
      final response = await dioClient.post(
        "/auth/resend-otp",
        data: {"email": email},
      );

      if (response.data == 200) {
        return response.data["message"] ?? "OTP Sent successfully";
      } else {
        throw ServerException(
          message: response.data["message"] ?? "Failed to send OTP",
          code: response.data["code"] ?? 'RESEND_OTP_FAILED',
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, "RESEND_OTP_ERROR");
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: "Failed to send OTP. Please try again",
        code: "RESEND_OTP_ERROR",
      );
    }
  }

  @override
  Future<String> verifyOTP(OtpVerificationRequest otpRequest) async {
    try {
      final response = await dioClient.post(
        "/verify-email-code",
        data: {"email": otpRequest.email, "code": otpRequest.otp},
      );

      if (response.statusCode == 200) {
        return response.data["message"] ?? "OTP verified successfully";
      } else {
        throw ServerException(
          message: response.data["message"] ?? "Invalid OTP",
          code: response.data["code"] ?? "INVALID_OTP",
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, "OTP_VERIFICATOIN_ERROR");
    } catch (e) {
      if (e is ServerException || e is ValidationException) rethrow;
      throw ServerException(
        message: "OTP verificatoin failed. Please try again",
        code: "OTP_VERIFICATION_ERRORL",
      );
    }
  }

  Never _handleApiError(ApiError error, String defaultCode) {
    if (error.statusCode != null) {
      switch (error.statusCode!) {
        case 400:
          throw ValidationException(
            message: error.message,
            code: "VALIDATION_ERROR",
          );
        case 401:
          throw AuthenticationException(
            message: error.message,
            code: "INVALID_CREDENTIALS",
          );
        case 403:
          throw AuthorizationException(
            message: error.message,
            code: "ACCESS_DENIED",
          );

        case 404:
          throw ServerException(message: error.message, code: "NEVER_FOUND");

        case 409:
          throw ValidationException(
            message: error.message,
            code: "EMAIL_ALREADY_EXISTS",
          );

        case 422:
          throw ValidationException(
            message: error.message,
            code: "VALIDATION_ERROR",
          );

        case 429:
          throw ServerException(
            message: error.message,
            code: "RATE_LIMIT_EXCEEDED",
          );

        case 408:
          throw TimeoutException(message: error.message, code: "TIMEOUT_ERROR");

        case 500:
          throw ServerException(message: error.message, code: "SERVER_ERROR");
        default:
          throw ServerException(message: error.message, code: "SERVER_ERROR");
      }
    } else {
      if (error.message.toLowerCase().contains("timeout")) {
        throw NetworkException(
          message: "Connection timeout. Please try again",
          code: "NETWORK_TIMEOUT",
        );
      } else {
        throw NetworkException(
          message: "Network error. Please check your connection",
          code: "NETWORK_ERROR",
        );
      }
    }
  }
}
