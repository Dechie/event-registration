// // lib/features/auth/data/datasource/auth_remote_datasource.dart
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/auth/data/models/login/login_request.dart';
import 'package:event_reg/features/auth/data/models/login/login_response.dart';
import 'package:event_reg/features/auth/data/models/otp/otp_verification_request.dart';
import 'package:event_reg/features/auth/data/models/registration/user_registration_request.dart';
import 'package:event_reg/features/auth/data/models/registration/user_registration_response.dart';
import 'package:flutter/material.dart' show debugPrint;

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
      debugPrint("register status: ${response.data["message"]}");

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
        debugPrint("server error because of non 200/201?");
        throw ServerException(
          message: response.data["message"] ?? "Registration Failed",
          code: response.data["code"] ?? 'REGISTRATION_FAILED',
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, 'REGISTRATION_ERROR');
    } catch (e) {
      debugPrint("is error here?");
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
