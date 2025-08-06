// lib/features/verification/data/datasource/verification_datasource.dart

import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/verification/data/models/verification_response.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../models/verification_request.dart';

abstract class VerificationRemoteDataSource {
  Future<VerificationResponse> verifyBadge(String badgeNumber, String verificationType);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final DioClient dioClient;

  VerificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<VerificationResponse> verifyBadge(String badgeNumber, String verificationType) async {
    try {
      debugPrint('🚀 DataSource: Verifying badge $badgeNumber for type: $verificationType');

      // Create request based on verification type
      VerificationRequest request;
      
      switch (verificationType.toLowerCase()) {
        case 'attendance':
          // For now, we'll use badge number as participant ID
          // In a real implementation, you'd extract participant_id and eventsession_id from the QR code
          request = VerificationRequest.attendance(
            participantId: badgeNumber,
            eventSessionId: '1', // You'll need to get this from QR code or context
          );
          break;
        case 'coupon':
          // For now, we'll use badge number as participant ID
          // In a real implementation, you'd extract participant_id and coupon_id from the QR code
          request = VerificationRequest.coupon(
            participantId: badgeNumber,
            couponId: '1', // You'll need to get this from QR code or context
          );
          break;
        case 'security':
        default:
          request = VerificationRequest.security(badgeNumber: badgeNumber);
          break;
      }

      debugPrint('📝 Request data: ${request.toJson()}');

      // Make API call to Laravel endpoint
      final response = await dioClient.post(
        "/qr/check/from-center",
        data: request.toJson(),
      );

      debugPrint('📥 DataSource: Response status ${response.statusCode}');
      debugPrint('📥 DataSource: Response data ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle nested data response or direct response
        final responseData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (responseData is! Map<String, dynamic>) {
          debugPrint('❌ Invalid response format: ${responseData.runtimeType}');
          throw ServerException(
            message: "Invalid response format from server",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }

        try {
          final verificationResponse = VerificationResponse.fromJson(
            responseData,
          );
          debugPrint('✅ DataSource: Successfully parsed response');
          return verificationResponse;
        } catch (e) {
          debugPrint('❌ Error parsing VerificationResponse: $e');
          throw ServerException(
            message: "Failed to parse verification response: $e",
            code: "PARSE_ERROR",
          );
        }
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Verification failed"
            : "Verification failed";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "VERIFICATION_FAILED"
            : "VERIFICATION_FAILED";

        debugPrint(
          '❌ API Error: $errorMessage (Status: ${response.statusCode})',
        );
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('❌ API Error during verification: ${e.message}');
      _handleApiError(e, "VERIFICATION_ERROR");
    } on FormatException catch (e) {
      debugPrint('❌ Format/Parse error during verification: $e');
      throw ServerException(
        message: "Invalid response format from server: $e",
        code: "PARSE_ERROR",
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during verification: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (e is ServerException) rethrow;
      throw ServerException(
        message: "An unexpected error occurred during verification: $e",
        code: "UNEXPECTED_VERIFICATION_ERROR",
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
          throw AuthorizationException(
            message: error.message,
            code: "ACCESS_DENIED",
          );
        case 404:
          // Badge not found
          throw ServerException(
            message: error.message.isEmpty
                ? "Badge number not found"
                : error.message,
            code: "BADGE_NOT_FOUND",
          );
        case 409:
          throw ValidationException(
            message: error.message,
            code: "CONFLICT_ERROR",
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