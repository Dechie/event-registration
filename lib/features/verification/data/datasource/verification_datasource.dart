// // lib/features/verification/data/datasource/verification_datasource.dart

// import 'package:event_reg/core/error/exceptions.dart';
// import 'package:event_reg/core/network/dio_client.dart';
// import 'package:event_reg/features/verification/data/models/verification_response.dart';
// import 'package:flutter/material.dart' show debugPrint;

// import '../models/coupon.dart';
// import '../models/verification_request.dart';

// abstract class VerificationRemoteDataSource {
//   Future<List<Coupon>> fetchParticipantCoupons(
//     String participantId,
//     String token,
//   );
//   Future<VerificationResponse> verifyBadge(
//     String badgeNumber,
//     String verificationType, {
//     String? eventSessionId,
//     String? sessionLocationId, // Add this parameter
//     String? couponId,
//     required String token,
//   });
// }

// class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
//   final DioClient dioClient;

//   VerificationRemoteDataSourceImpl({required this.dioClient});

//   @override
//   Future<List<Coupon>> fetchParticipantCoupons(
//     String participantId,
//     String token,
//   ) async {
//     try {
//       debugPrint(
//         '🚀 DataSource: Fetching coupons for participant $participantId',
//       );

//       final response = await dioClient.get(
//         "/my-coupons", // Based on your backend route
//         token: token,
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         final couponsData = data is Map<String, dynamic>
//             ? (data["data"] ?? data)
//             : data;

//         if (couponsData is List) {
//           return couponsData
//               .map((couponJson) => Coupon.fromJson(couponJson))
//               .toList();
//         } else {
//           throw ServerException(
//             message: "Invalid coupons response format",
//             code: "INVALID_RESPONSE_FORMAT",
//           );
//         }
//       } else {
//         throw ServerException(
//           message: "Failed to fetch coupons",
//           code: "FETCH_COUPONS_FAILED",
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ DataSource: Error fetching coupons - $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<VerificationResponse> verifyBadge(
//     String badgeNumber,
//     String verificationType, {
//     String? eventSessionId,
//     String? sessionLocationId,
//     String? couponId,
//     required String token,
//   }) async {
//     try {
//       debugPrint(
//         '🚀 DataSource: Verifying badge $badgeNumber for type: $verificationType',
//       );
//       VerificationRequest request;
//       switch (verificationType.toLowerCase()) {
//         case 'attendance':
//           request = VerificationRequest.attendance(
//             badgeNumber: badgeNumber,
//             eventSessionId: eventSessionId ?? '1', // Use actual eventSessionId
//             sessionLocationId:
//                 sessionLocationId ?? '1', // Use actual sessionLocationId
//           );
//           break;
//         case 'coupon':
//           request = VerificationRequest.coupon(
//             badgeNumber: badgeNumber,
//             couponId: couponId ?? '1',
//           );
//           break;
//         case 'info':
//           request = VerificationRequest.info(badgeNumber: badgeNumber);
//           break;
//         case 'security':
//         default:
//           request = VerificationRequest.security(badgeNumber: badgeNumber);
//           break;
//       }
//       var dataJson = request.toJson();
//       debugPrint('📝 Request data:  $dataJson');

//       final response = await dioClient.post(
//         "/qr/check",
//         data: dataJson,
//         token: token,
//       );

//       debugPrint('🔥 DataSource: Response status ${response.statusCode}');
//       debugPrint('🔥 DataSource: Response data ${response.data}');

//       // Handle both success (200) and error responses
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = response.data;
//         final responseData = data is Map<String, dynamic> ? data : <String, dynamic>{};

//         try {
//           final verificationResponse = VerificationResponse.fromJson(
//             responseData,
//           );
//           debugPrint('✅ DataSource: Successfully parsed response');

//           return verificationResponse;
//         } catch (e) {
//           debugPrint('❌ Error parsing VerificationResponse: $e');
//           throw ServerException(
//             message: "Failed to parse verification response: $e",
//             code: "PARSE_ERROR",
//           );
//         }
//       } else {
//         // Handle error responses (404, 409, 422, etc.)
//         final data = response.data;
//         String errorMessage = "Verification failed";
//         String errorCode = "VERIFICATION_FAILED";

//         if (data is Map<String, dynamic>) {
//           errorMessage = data["message"] ?? errorMessage;

//           // Map specific error messages from backend
//           if (errorMessage.contains('not found') ||
//               errorMessage.contains('not approved')) {
//             errorCode = "PARTICIPANT_NOT_FOUND";
//           } else if (errorMessage.contains('Already checked in')) {
//             errorCode = "ALREADY_CHECKED_IN";
//           } else if (errorMessage.contains('No active attendance round')) {
//             errorCode = "NO_ACTIVE_ROUND";
//           } else if (errorMessage.contains('Usage limit reached')) {
//             errorCode = "USAGE_LIMIT_REACHED";
//           } else if (errorMessage.contains('Coupon is inactive')) {
//             errorCode = "COUPON_INACTIVE";
//           }
//         }

//         throw ServerException(message: errorMessage, code: errorCode);
//       }
//     } catch (e) {
//       debugPrint('❌ DataSource: Unexpected error - $e');
//       rethrow;
//     }
//   }

//   Never _handleApiError(ApiError error, String defaultCode) {
//     debugPrint(
//       'Handling API Error: ${error.message}, Status: ${error.statusCode}',
//     );

//     if (error.statusCode != null) {
//       switch (error.statusCode!) {
//         case 400:
//           throw ValidationException(
//             message: error.message,
//             code: "VALIDATION_ERROR",
//           );
//         case 401:
//           throw AuthenticationException(
//             message: error.message,
//             code: "INVALID_CREDENTIALS",
//           );
//         case 403:
//           throw AuthorizationException(
//             message: error.message,
//             code: "ACCESS_DENIED",
//           );
//         case 404:
//           // Badge not found
//           throw ServerException(
//             message: error.message.isEmpty
//                 ? "Badge number not found"
//                 : error.message,
//             code: "BADGE_NOT_FOUND",
//           );
//         case 409:
//           throw ValidationException(
//             message: error.message,
//             code: "CONFLICT_ERROR",
//           );
//         case 422:
//           throw ValidationException(
//             message: error.message,
//             code: "VALIDATION_ERROR",
//           );
//         case 429:
//           throw ServerException(
//             message: error.message,
//             code: "RATE_LIMIT_EXCEEDED",
//           );
//         case 408:
//           throw TimeoutException(message: error.message, code: "TIMEOUT_ERROR");
//         case 500:
//         case 502:
//         case 503:
//         case 504:
//           throw ServerException(message: error.message, code: "SERVER_ERROR");
//         default:
//           throw ServerException(message: error.message, code: "SERVER_ERROR");
//       }
//     } else {
//       if (error.message.toLowerCase().contains("timeout")) {
//         throw NetworkException(
//           message: "Connection timeout. Please try again",
//           code: "NETWORK_TIMEOUT",
//         );
//       } else {
//         throw NetworkException(
//           message: "Network error. Please check your connection",
//           code: "NETWORK_ERROR",
//         );
//       }
//     }
//   }
// }

// lib/features/verification/data/datasource/verification_datasource.dart

import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/verification/data/models/verification_response.dart';
import 'package:flutter/material.dart' show debugPrint;

// Import attendance models
import '../../../attendance/data/models/attendance_event_model.dart';
import '../models/coupon.dart';
import '../models/verification_request.dart';

abstract class VerificationRemoteDataSource {
  Future<AttendanceEventModel> fetchEventDetails(String eventId, String token);

  // Merged attendance methods
  Future<List<AttendanceEventModel>> fetchEventsForAttendance(String token);

  // Original verification methods
  Future<List<Coupon>> fetchParticipantCoupons(
    String participantId,
    String token,
  );
  Future<void> markAttendance(
    String badgeNumber,
    String eventSessionId,
    String sessionLocationId,
    String token,
  );
  Future<VerificationResponse> verifyBadge(
    String badgeNumber,
    String verificationType, {
    String? eventSessionId,
    String? sessionLocationId,
    String? couponId,
    required String token,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final DioClient dioClient;

  VerificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AttendanceEventModel> fetchEventDetails(
    String eventId,
    String token,
  ) async {
    try {
      debugPrint('🚀 DataSource: Fetching event details for event $eventId');

      if (token.isEmpty) {
        debugPrint('❌ DataSource: No authentication token found');
        throw const AuthenticationException(
          message: "Authentication token not found",
          code: "TOKEN_REQUIRED",
        );
      }

      final response = await dioClient.get("/events/$eventId", token: token);

      debugPrint(
        'DataSource: Event details response status: ${response.statusCode}',
      );
      debugPrint('DataSource: Event details response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final eventData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (eventData is Map<String, dynamic>) {
          debugPrint('✅ DataSource: Successfully parsed event details');
          return AttendanceEventModel.fromJson(eventData);
        } else {
          debugPrint(
            '❌ DataSource: Invalid event response format: ${eventData.runtimeType}',
          );
          throw const ServerException(
            message: "Invalid event response format",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Failed to fetch event details"
            : "Failed to fetch event details";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "FETCH_EVENT_DETAILS_FAILED"
            : "FETCH_EVENT_DETAILS_FAILED";

        debugPrint('❌ DataSource: Event details fetch failed: $errorMessage');
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint(
        '❌ DataSource: API Error fetching event details: ${e.message}',
      );
      _handleApiError(e, "FETCH_EVENT_DETAILS_ERROR");
    } on FormatException catch (e) {
      debugPrint('❌ DataSource: Format/Parse error fetching event details: $e');
      throw ServerException(
        message: "Invalid response format from server: $e",
        code: "PARSE_ERROR",
      );
    } catch (e) {
      debugPrint('❌ DataSource: Unexpected error fetching event details: $e');
      if (e is ServerException ||
          e is AuthenticationException ||
          e is ValidationException ||
          e is NetworkException ||
          e is TimeoutException) {
        rethrow;
      }
      throw ServerException(
        message:
            "An unexpected error occurred while fetching event details: $e",
        code: "UNEXPECTED_FETCH_EVENT_DETAILS_ERROR",
      );
    }
  }

  // Merged attendance methods
  @override
  Future<List<AttendanceEventModel>> fetchEventsForAttendance(
    String token,
  ) async {
    try {
      debugPrint('🚀 DataSource: Fetching events for attendance');

      if (token.isEmpty) {
        debugPrint('❌ DataSource: No authentication token found');
        throw const AuthenticationException(
          message: "Authentication token not found",
          code: "TOKEN_REQUIRED",
        );
      }

      final response = await dioClient.get("/fetch-events", token: token);

      debugPrint('DataSource: Events response status: ${response.statusCode}');
      debugPrint('DataSource: Events response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data is List ? data : (data["data"] ?? []);

        if (eventsData is List) {
          debugPrint(
            '✅ DataSource: Successfully parsed ${eventsData.length} events',
          );

          return eventsData.map((eventJson) {
            try {
              return AttendanceEventModel.fromJson(eventJson);
            } catch (e) {
              debugPrint('❌ DataSource: Error parsing event: $e');
              debugPrint('Event JSON: $eventJson');
              rethrow;
            }
          }).toList();
        } else {
          debugPrint(
            '❌ DataSource: Invalid events response format: ${eventsData.runtimeType}',
          );
          throw const ServerException(
            message: "Invalid events response format",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Failed to fetch events"
            : "Failed to fetch events";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "FETCH_EVENTS_FAILED"
            : "FETCH_EVENTS_FAILED";

        debugPrint('❌ DataSource: Events fetch failed: $errorMessage');
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('❌ DataSource: API Error fetching events: ${e.message}');
      _handleApiError(e, "FETCH_EVENTS_ERROR");
    } on FormatException catch (e) {
      debugPrint('❌ DataSource: Format/Parse error fetching events: $e');
      throw ServerException(
        message: "Invalid response format from server: $e",
        code: "PARSE_ERROR",
      );
    } catch (e) {
      debugPrint('❌ DataSource: Unexpected error fetching events: $e');
      if (e is ServerException ||
          e is AuthenticationException ||
          e is ValidationException ||
          e is NetworkException ||
          e is TimeoutException) {
        rethrow;
      }
      throw ServerException(
        message: "An unexpected error occurred while fetching events: $e",
        code: "UNEXPECTED_FETCH_EVENTS_ERROR",
      );
    }
  }

  // Original verification methods
  @override
  Future<List<Coupon>> fetchParticipantCoupons(
    String participantId,
    String token,
  ) async {
    try {
      debugPrint(
        '🚀 DataSource: Fetching coupons for participant $participantId',
      );

      final response = await dioClient.get("/my-coupons", token: token);

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
  Future<void> markAttendance(
    String badgeNumber,
    String eventSessionId,
    String sessionLocationId,
    String token,
  ) async {
    try {
      debugPrint('🚀 DataSource: Marking attendance for badge $badgeNumber');
      debugPrint(
        'Event Session ID: $eventSessionId, Location ID: $sessionLocationId',
      );

      if (token.isEmpty) {
        debugPrint('❌ DataSource: No authentication token found');
        throw const AuthenticationException(
          message: "Authentication token not found",
          code: "TOKEN_REQUIRED",
        );
      }

      // Validate input parameters
      if (badgeNumber.trim().isEmpty) {
        throw const ValidationException(
          message: "Badge number cannot be empty",
          code: "VALIDATION_ERROR",
        );
      }

      if (eventSessionId.trim().isEmpty) {
        throw const ValidationException(
          message: "Event session ID cannot be empty",
          code: "VALIDATION_ERROR",
        );
      }

      if (sessionLocationId.trim().isEmpty) {
        throw const ValidationException(
          message: "Session location ID cannot be empty",
          code: "VALIDATION_ERROR",
        );
      }

      final requestData = {
        'type': 'attendance',
        'badge_number': badgeNumber.trim(),
        'eventsession_id': int.tryParse(eventSessionId) ?? 1,
        'sessionlocation_id': int.tryParse(sessionLocationId) ?? 1,
      };

      debugPrint('DataSource: Attendance request data: $requestData');

      final response = await dioClient.post(
        "/qr/check",
        data: requestData,
        token: token,
      );

      debugPrint(
        'DataSource: Attendance response status: ${response.statusCode}',
      );
      debugPrint('DataSource: Attendance response data: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('✅ DataSource: Attendance marked successfully');
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Failed to mark attendance"
            : "Failed to mark attendance";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "MARK_ATTENDANCE_FAILED"
            : "MARK_ATTENDANCE_FAILED";

        debugPrint('❌ DataSource: Attendance marking failed: $errorMessage');
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('❌ DataSource: API Error marking attendance: ${e.message}');
      _handleApiError(e, "MARK_ATTENDANCE_ERROR");
    } catch (e) {
      debugPrint('❌ DataSource: Unexpected error marking attendance: $e');
      if (e is ServerException ||
          e is AuthenticationException ||
          e is ValidationException ||
          e is NetworkException ||
          e is TimeoutException) {
        rethrow;
      }
      throw ServerException(
        message: "An unexpected error occurred while marking attendance: $e",
        code: "UNEXPECTED_MARK_ATTENDANCE_ERROR",
      );
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
            eventSessionId: eventSessionId ?? '1',
            sessionLocationId: sessionLocationId ?? '1',
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
      debugPrint('🔍 Request data: $dataJson');

      final response = await dioClient.post(
        "/qr/check",
        data: dataJson,
        token: token,
      );

      debugPrint('🔥 DataSource: Response status ${response.statusCode}');
      debugPrint('🔥 DataSource: Response data ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final responseData = data is Map<String, dynamic>
            ? data
            : <String, dynamic>{};

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
        final data = response.data;
        String errorMessage = "Verification failed";
        String errorCode = "VERIFICATION_FAILED";

        if (data is Map<String, dynamic>) {
          errorMessage = data["message"] ?? errorMessage;

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
    } on ApiError catch (e) {
      debugPrint('❌ DataSource: API Error marking attendance: ${e.message}');
      _handleApiError(e, "MARK_ATTENDANCE_ERROR");
    } catch (e) {
      debugPrint('❌ DataSource: Unexpected error - $e');
      rethrow;
    }
  }

  Never _handleApiError(ApiError error, String defaultCode) {
    debugPrint(
      'Handling API Error: ${error.message}, Status: ${error.statusCode}',
    );

    var errorMessage = error.message;
    var errorCode = defaultCode;
    // if (errorMessage.contains('not found') ||
    //     errorMessage.contains('not approved')) {
    //   errorCode = "PARTICIPANT_NOT_FOUND";
    // } else if (errorMessage.contains('Already checked in')) {
    //   errorCode = "ALREADY_CHECKED_IN";
    // } else if (errorMessage.contains('No active attendance round')) {
    //   errorCode = "NO_ACTIVE_ROUND";
    // } else if (errorMessage.contains('Usage limit reached')) {
    //   errorCode = "USAGE_LIMIT_REACHED";
    // } else if (errorMessage.contains('Coupon is inactive')) {
    //   errorCode = "COUPON_INACTIVE";
    // }

    if (error.statusCode != null) {
      switch (error.statusCode!) {
        case 400:
          // Handle specific errors
          if (error.message.toLowerCase().contains('badge')) {
            throw ValidationException(
              message: error.message,
              code: "INVALID_BADGE_NUMBER",
            );
          } else if (error.message.toLowerCase().contains('session')) {
            throw ValidationException(
              message: error.message,
              code: "INVALID_SESSION",
            );
          } else if (error.message.toLowerCase().contains('already')) {
            throw ValidationException(
              message: error.message,
              code: "ATTENDANCE_ALREADY_MARKED",
            );
          }
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
          if (errorMessage.contains('Already checked in')) {
            errorCode = "ATTENDANCE_ALREADY_MARKED";
            throw ValidationException(
              message: error.message,
              code: "ATTENDANCE_ALREADY_MARKED",
            );
          }
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
