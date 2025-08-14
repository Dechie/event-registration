// lib/features/verification/data/datasource/verification_datasource.dart

import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/verification/data/models/verification_response.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../models/coupon.dart';
import '../models/verification_request.dart';

abstract class VerificationRemoteDataSource {
  Future<List<Coupon>> fetchParticipantCoupons(
    String participantId,
    String token,
  );
  Future<VerificationResponse> verifyBadge(
    String badgeNumber,
    String verificationType, {
    String? eventSessionId,
    String? sessionLocationId, // Add this parameter
    String? couponId,
    required String token,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final DioClient dioClient;

  VerificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<Coupon>> fetchParticipantCoupons(
    String participantId,
    String token,
  ) async {
    try {
      debugPrint(
        '🚀 DataSource: Fetching coupons for participant $participantId',
      );

      final response = await dioClient.get(
        "/my-coupons", // Based on your backend route
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final couponsData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (couponsData is List) {
          return couponsData
              .map((couponJson) => Coupon.fromJson(couponJson))
              .toList();
        } else {
          throw ServerException(
            message: "Invalid coupons response format",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }
      } else {
        throw ServerException(
          message: "Failed to fetch coupons",
          code: "FETCH_COUPONS_FAILED",
        );
      }
    } catch (e) {
      debugPrint('❌ DataSource: Error fetching coupons - $e');
      rethrow;
    }
  }

  @override
  Future<VerificationResponse> verifyBadge(
    String badgeNumber,
    String verificationType, {
    String? eventSessionId,
    String? sessionLocationId,
    String? couponId,
    required String token,
  }) async {
    try {
      debugPrint(
        '🚀 DataSource: Verifying badge $badgeNumber for type: $verificationType',
      );
      VerificationRequest request;
      switch (verificationType.toLowerCase()) {
        case 'attendance':
          request = VerificationRequest.attendance(
            badgeNumber: badgeNumber,
            eventSessionId: eventSessionId ?? '1', // Use actual eventSessionId
            sessionLocationId:
                sessionLocationId ?? '1', // Use actual sessionLocationId
          );
          break;
        case 'coupon':
          request = VerificationRequest.coupon(
            badgeNumber: badgeNumber,
            couponId: couponId ?? '1',
          );
          break;
        case 'info':
          request = VerificationRequest.info(badgeNumber: badgeNumber);
          break;
        case 'security':
        default:
          request = VerificationRequest.security(badgeNumber: badgeNumber);
          break;
      }
      var dataJson = request.toJson();
      debugPrint('📝 Request data:  $dataJson');

      final response = await dioClient.post(
        "/qr/check",
        data: dataJson,
        token: token,
      );

      debugPrint('🔥 DataSource: Response status ${response.statusCode}');
      debugPrint('🔥 DataSource: Response data ${response.data}');

      // Handle both success (200) and error responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final responseData = data is Map<String, dynamic> ? data : <String, dynamic>{};

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
        // Handle error responses (404, 409, 422, etc.)
        final data = response.data;
        String errorMessage = "Verification failed";
        String errorCode = "VERIFICATION_FAILED";

        if (data is Map<String, dynamic>) {
          errorMessage = data["message"] ?? errorMessage;

          // Map specific error messages from backend
          if (errorMessage.contains('not found') ||
              errorMessage.contains('not approved')) {
            errorCode = "PARTICIPANT_NOT_FOUND";
          } else if (errorMessage.contains('Already checked in')) {
            errorCode = "ALREADY_CHECKED_IN";
          } else if (errorMessage.contains('No active attendance round')) {
            errorCode = "NO_ACTIVE_ROUND";
          } else if (errorMessage.contains('Usage limit reached')) {
            errorCode = "USAGE_LIMIT_REACHED";
          } else if (errorMessage.contains('Coupon is inactive')) {
            errorCode = "COUPON_INACTIVE";
          }
        }

        throw ServerException(message: errorMessage, code: errorCode);
      }
    } catch (e) {
      debugPrint('❌ DataSource: Unexpected error - $e');
      rethrow;
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
