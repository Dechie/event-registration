// lib/features/auth/data/datasource/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/features/auth/data/models/login_request.dart';
import 'package:event_reg/features/auth/data/models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest loginRequest);
  Future<void> logout();
  Future<String> forgotPassword(String email);
  Future<String> resetPassword({required String token, required String newPassword});
  Future<LoginResponse> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Login failed',
          code: response.data['code'] ?? 'LOGIN_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT_ERROR',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          message: 'No internet connection. Please check your network.',
          code: 'NETWORK_ERROR',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 401:
            throw ServerException(
              message: responseData['message'] ?? 'Invalid credentials',
              code: 'INVALID_CREDENTIALS',
            );
          case 403:
            throw ServerException(
              message: responseData['message'] ?? 'Access denied',
              code: 'ACCESS_DENIED',
            );
          case 404:
            throw ServerException(
              message: responseData['message'] ?? 'User not found',
              code: 'USER_NOT_FOUND',
            );
          case 422:
            throw ServerException(
              message: responseData['message'] ?? 'Invalid input data',
              code: 'VALIDATION_ERROR',
            );
          case 429:
            throw ServerException(
              message: responseData['message'] ?? 'Too many login attempts',
              code: 'RATE_LIMIT_EXCEEDED',
            );
          default:
            throw ServerException(
              message: responseData['message'] ?? 'Server error occurred',
              code: 'SERVER_ERROR',
            );
        }
      } else {
        throw ServerException(
          message: 'Unknown server error occurred',
          code: 'UNKNOWN_SERVER_ERROR',
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'An unexpected error occurred',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } on DioException catch (e) {
      // Logout can fail silently on server side
      print('Server logout failed: ${e.message}');
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await dioClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return response.data['message'] ?? 'Password reset email sent successfully';
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to send reset email',
          code: response.data['code'] ?? 'FORGOT_PASSWORD_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          message: 'Connection timeout. Please try again.',
          code: 'TIMEOUT_ERROR',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          message: 'No internet connection.',
          code: 'NETWORK_ERROR',
        );
      } else if (e.response != null) {
        final responseData = e.response!.data;
        throw ServerException(
          message: responseData['message'] ?? 'Failed to send reset email',
          code: responseData['code'] ?? 'FORGOT_PASSWORD_ERROR',
        );
      } else {
        throw ServerException(
          message: 'Failed to send password reset email',
          code: 'FORGOT_PASSWORD_ERROR',
        );
      }
    }
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return response.data['message'] ?? 'Password reset successfully';
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to reset password',
          code: response.data['code'] ?? 'RESET_PASSWORD_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 400) {
        throw ServerException(
          message: 'Invalid or expired reset token',
          code: 'INVALID_RESET_TOKEN',
        );
      }
      throw ServerException(
        message: 'Failed to reset password',
        code: 'RESET_PASSWORD_ERROR',
      );
    }
  }

  @override
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to refresh token',
          code: 'TOKEN_REFRESH_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        throw ServerException(
          message: 'Refresh token expired',
          code: 'REFRESH_TOKEN_EXPIRED',
        );
      }
      throw ServerException(
        message: 'Failed to refresh authentication',
        code: 'TOKEN_REFRESH_ERROR',
      );
    }
  }
}
