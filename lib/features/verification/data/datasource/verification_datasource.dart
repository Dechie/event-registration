// lib/features/verification/data/datasource/verification_datasource.dart

import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/verification/data/models/verification_response.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../models/coupon.dart';
import '../models/verification_request.dart';

abstract class VerificationRemoteDataSource {
  Future<VerificationResponse> verifyBadge(
    String badgeNumber,
    String verificationType, {
    String? eventSessionId,
    String? couponId,
    required String token,
  });
  Future<List<Coupon>> fetchParticipantCoupons(String participantId, String token);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final DioClient dioClient;

  VerificationRemoteDataSourceImpl({required this.dioClient});

  @override
Future<List<Coupon>> fetchParticipantCoupons(String participantId, String token) async {
  try {
    debugPrint('🚀 DataSource: Fetching coupons for participant $participantId');
    
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
        return couponsData.map((couponJson) => Coupon.fromJson(couponJson)).toList();
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
            eventSessionId: eventSessionId ?? '1',
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

      debugPrint('📥 DataSource: Response status ${response.statusCode}');
      debugPrint('📥 DataSource: Response data ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
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
          debugPrint("response data:");
          debugPrint("{");
          for (var entry in responseData.entries) {
            if (entry.value is Map<String, dynamic>) {
              debugPrint("  {");
              for (var valueEntry in entry.value.entries) {
                debugPrint(
                  "    \"${valueEntry.key}\": \"${valueEntry.value}\"",
                );
              }
              debugPrint("  }");
              continue;
            }
            debugPrint("  \"${entry.key}\": \"${entry.value}\"");
          }
          debugPrint("}");
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
