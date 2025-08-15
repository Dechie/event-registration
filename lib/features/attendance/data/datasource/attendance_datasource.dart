import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../models/attendance_event_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceEventModel> fetchEventDetails(String eventId);
  Future<List<AttendanceEventModel>> fetchEventsForAttendance();
  Future<void> markAttendance(
    String badgeNumber,
    String eventSessionId,
    String sessionLocationId,
  );
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient dioClient;
  final UserDataService userDataService;

  AttendanceRemoteDataSourceImpl({
    required this.dioClient,
    required this.userDataService,
  });

  @override
  Future<AttendanceEventModel> fetchEventDetails(String eventId) async {
    try {
      debugPrint('🚀 DataSource: Fetching event details for event $eventId');

      final token = await userDataService.getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ DataSource: No authentication token found');
        throw const AuthenticationException(
          message: "Authentication token not found",
          code: "TOKEN_REQUIRED",
        );
      }
      debugPrint("user token: $token");

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

  @override
  Future<List<AttendanceEventModel>> fetchEventsForAttendance() async {
    try {
      debugPrint('🚀 DataSource: Fetching events for attendance');

      final token = await userDataService.getAuthToken();
      if (token == null || token.isEmpty) {
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

  @override
  Future<void> markAttendance(
    String badgeNumber,
    String eventSessionId,
    String sessionLocationId,
  ) async {
    try {
      debugPrint('🚀 DataSource: Marking attendance for badge $badgeNumber');
      debugPrint(
        'Event Session ID: $eventSessionId, Location ID: $sessionLocationId',
      );

      final token = await userDataService.getAuthToken();
      if (token == null || token.isEmpty) {
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

  /// Handles API errors and converts them to appropriate exceptions
  Never _handleApiError(ApiError error, String defaultCode) {
    debugPrint(
      'Handling API Error: ${error.message}, Status: ${error.statusCode}',
    );

    if (error.statusCode != null) {
      switch (error.statusCode!) {
        case 400:
          // Handle specific attendance validation errors
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
            message: error.message.isEmpty
                ? "Authentication failed. Please log in again."
                : error.message,
            code: "INVALID_CREDENTIALS",
          );
        case 403:
          if (error.message.toLowerCase().contains('access')) {
            throw AuthorizationException(
              message: error.message,
              code: "ACCESS_DENIED",
            );
          } else if (error.message.toLowerCase().contains('permission')) {
            throw AuthorizationException(
              message: error.message,
              code: "INSUFFICIENT_PERMISSIONS",
            );
          }
          throw AuthorizationException(
            message: error.message,
            code: "FORBIDDEN",
          );
        case 404:
          if (error.message.toLowerCase().contains('event')) {
            throw ServerException(
              message: "Event not found",
              code: "EVENT_NOT_FOUND",
            );
          } else if (error.message.toLowerCase().contains('session')) {
            throw ServerException(
              message: "Session not found",
              code: "SESSION_NOT_FOUND",
            );
          } else if (error.message.toLowerCase().contains('badge')) {
            throw ValidationException(
              message: "Badge not found",
              code: "BADGE_NOT_FOUND",
            );
          }
          throw ServerException(message: error.message, code: "NOT_FOUND");
        case 409:
          throw ValidationException(
            message: error.message,
            code: "ATTENDANCE_ALREADY_MARKED",
          );
        case 422:
          throw ValidationException(
            message: error.message,
            code: "VALIDATION_ERROR",
          );
        case 429:
          throw ServerException(
            message: error.message.isEmpty
                ? "Too many requests. Please wait before trying again."
                : error.message,
            code: "RATE_LIMIT_EXCEEDED",
          );
        case 408:
          throw TimeoutException(
            message: error.message.isEmpty
                ? "Request timeout. Please try again."
                : error.message,
            code: "TIMEOUT_ERROR",
          );
        case 500:
        case 502:
        case 503:
        case 504:
          throw ServerException(
            message: error.message.isEmpty
                ? "Server error. Please try again later."
                : error.message,
            code: "SERVER_ERROR",
          );
        default:
          throw ServerException(
            message: error.message.isEmpty
                ? "An error occurred. Please try again."
                : error.message,
            code: "SERVER_ERROR",
          );
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
