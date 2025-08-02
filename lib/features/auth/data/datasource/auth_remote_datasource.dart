// // lib/features/auth/data/datasource/auth_remote_datasource.dart
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/auth/data/models/registration/user_registration_response.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../models/login/login_request.dart';
import '../models/login/login_response.dart';
import '../models/otp/otp_verification_request.dart';
import '../models/registration/user_registration_request.dart';

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
      debugPrint('Attempting login for: ${loginRequest.email}');

      final response = await dioClient.post(
        "/login",
        data: {"email": loginRequest.email, "password": loginRequest.password},
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('Raw response data type: ${data.runtimeType}');
        debugPrint('Raw response data: $data');

        // Handle both nested data and direct response formats
        final loginData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (loginData is! Map<String, dynamic>) {
          debugPrint('❌ Invalid response format: ${loginData.runtimeType}');
          throw ServerException(
            message: "Invalid response format from server",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }

        debugPrint('✅ Parsing login data: $loginData');

        try {
          final loginResponse = LoginResponse.fromJson(loginData);
          debugPrint('✅ Successfully parsed LoginResponse');
          return loginResponse;
        } catch (e) {
          debugPrint('❌ Error parsing LoginResponse: $e');
          debugPrint('❌ Login data was: $loginData');
          throw ServerException(
            message: "Failed to parse login response: $e",
            code: "PARSE_ERROR",
          );
        }
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Login failed"
            : "Login failed";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "LOGIN_FAILED"
            : "LOGIN_FAILED";

        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('API Error during login: ${e.message}');
      _handleApiError(e, "LOGIN_ERROR");
    } on FormatException catch (e) {
      debugPrint('❌ Format/Parse error during login: $e');
      throw ServerException(
        message: "Invalid response format from server: $e",
        code: "PARSE_ERROR",
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during login: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (e is ServerException) rethrow;
      throw ServerException(
        message: "An unexpected error occurred during login: $e",
        code: "UNEXPECTED_LOGIN_ERROR",
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post("/logout");
      debugPrint('Logout successful');
    } on ApiError catch (e) {
      debugPrint("Server logout failed: ${e.message}");
      // Don't throw error for logout as local cleanup is more important
    } catch (e) {
      debugPrint("Server logout failed: $e");
      // Don't throw error for logout as local cleanup is more important
    }
  }

  @override
  Future<UserRegistrationResponse> registerUser(
    UserRegistrationRequest registrationRequest,
  ) async {
    try {
      debugPrint('Attempting registration for: ${registrationRequest.email}');

      final response = await dioClient.post(
        "/register",
        data: registrationRequest.toJson(),
      );

      debugPrint("Registration status: ${response.statusCode}");
      debugPrint("Registration response: ${response.data}");

      if ([200, 201].contains(response.statusCode)) {
        final data = response.data;
        final responseData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (responseData is! Map<String, dynamic>) {
          throw ServerException(
            message: "Invalid response format from server",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }

        return UserRegistrationResponse(
          message: responseData["message"] ?? "Registration successful",
          userId: responseData["user_id"] ?? responseData["id"] ?? "",
          email: responseData["email"] ?? registrationRequest.email,
          otpSent: responseData["otp_sent"] ?? true,
          otpToken: responseData["otp_token"],
        );
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Registration failed"
            : "Registration failed";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "REGISTRATION_FAILED"
            : "REGISTRATION_FAILED";

        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('API Error during registration: ${e.message}');
      _handleApiError(e, 'REGISTRATION_ERROR');
    } catch (e) {
      debugPrint("Unexpected error during registration: $e");
      if (e is ServerException || e is ValidationException) rethrow;
      throw ServerException(
        message: "Registration failed. Please try again",
        code: "REGISTRATION_ERROR",
      );
    }
  }

  @override
  Future<String> resendOTP(String email) async {
    try {
      debugPrint('Attempting to resend OTP for: $email');

      final response = await dioClient.post(
        "/auth/resend-otp",
        data: {"email": email},
      );

      debugPrint("Resend OTP status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final message = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "OTP sent successfully"
            : "OTP sent successfully";
        return message;
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Failed to send OTP"
            : "Failed to send OTP";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "RESEND_OTP_FAILED"
            : "RESEND_OTP_FAILED";

        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('API Error during OTP resend: ${e.message}');
      _handleApiError(e, "RESEND_OTP_ERROR");
    } catch (e) {
      debugPrint("Unexpected error during OTP resend: $e");
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
      debugPrint('Attempting to verify OTP for: ${otpRequest.email}');

      final response = await dioClient.post(
        "/verify-email-code",
        data: {"email": otpRequest.email, "code": otpRequest.otp},
      );

      debugPrint("OTP verification status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final message = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "OTP verified successfully"
            : "OTP verified successfully";
        return message;
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Invalid OTP"
            : "Invalid OTP";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "INVALID_OTP"
            : "INVALID_OTP";

        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('API Error during OTP verification: ${e.message}');
      _handleApiError(e, "OTP_VERIFICATION_ERROR");
    } catch (e) {
      debugPrint("Unexpected error during OTP verification: $e");
      if (e is ServerException || e is ValidationException) rethrow;
      throw ServerException(
        message: "OTP verification failed. Please try again",
        code: "OTP_VERIFICATION_ERROR",
      );
    }
  }

  Never _handleApiError(ApiError error, String defaultCode) {
    debugPrint(
      'Handling API Error: ${error.message}, Status: ${error.statusCode}',
    );

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
          // Handle email verification requirement
          if (error.message.toLowerCase().contains('verify')) {
            throw AuthenticationException(
              message: error.message,
              code: "EMAIL_NOT_VERIFIED",
            );
          }
          throw AuthorizationException(
            message: error.message,
            code: "ACCESS_DENIED",
          );
        case 404:
          throw ServerException(message: error.message, code: "NOT_FOUND");
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
        case 502:
        case 503:
        case 504:
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
