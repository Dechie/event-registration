// lib/features/reports/data/datasource/report_datasource.dart
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../models/event_report.dart';
import '../models/session_report.dart';

abstract class ReportRemoteDataSource {
  Future<EventReport> fetchEventReport(int eventId);
  Future<SessionReport> fetchSessionReport(int sessionId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient dioClient;
  final UserDataService userDataService;

  ReportRemoteDataSourceImpl({
    required this.dioClient,
    required this.userDataService,
  });

  @override
  Future<EventReport> fetchEventReport(int eventId) async {
    try {
      debugPrint('🚀 DataSource: Fetching event report for event $eventId');

      final token = await userDataService.getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ DataSource: No authentication token found');
        throw const AuthenticationException(
          message: "Authentication token not found",
          code: "TOKEN_REQUIRED",
        );
      }

      final response = await dioClient.get("/event-report/$eventId", token: token);

      debugPrint('DataSource: Event report response status: ${response.statusCode}');
      debugPrint('DataSource: Event report response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final reportData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (reportData is Map<String, dynamic>) {
          debugPrint('✅ DataSource: Successfully parsed event report');
          return EventReport.fromJson(reportData);
        } else {
          debugPrint('❌ DataSource: Invalid event report response format: ${reportData.runtimeType}');
          throw const ServerException(
            message: "Invalid event report response format",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Failed to fetch event report"
            : "Failed to fetch event report";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "FETCH_EVENT_REPORT_FAILED"
            : "FETCH_EVENT_REPORT_FAILED";

        debugPrint('❌ DataSource: Event report fetch failed: $errorMessage');
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('❌ DataSource: API Error fetching event report: ${e.message}');
      _handleApiError(e, "FETCH_EVENT_REPORT_ERROR");
    } on FormatException catch (e) {
      debugPrint('❌ DataSource: Format/Parse error fetching event report: $e');
      throw ServerException(
        message: "Invalid response format from server: $e",
        code: "PARSE_ERROR",
      );
    } catch (e) {
      debugPrint('❌ DataSource: Unexpected error fetching event report: $e');
      if (e is ServerException ||
          e is AuthenticationException ||
          e is ValidationException ||
          e is NetworkException ||
          e is TimeoutException) {
        rethrow;
      }
      throw ServerException(
        message: "An unexpected error occurred while fetching event report: $e",
        code: "UNEXPECTED_FETCH_EVENT_REPORT_ERROR",
      );
    }
  }

  @override
  Future<SessionReport> fetchSessionReport(int sessionId) async {
    try {
      debugPrint('🚀 DataSource: Fetching session report for session $sessionId');

      final token = await userDataService.getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ DataSource: No authentication token found');
        throw const AuthenticationException(
          message: "Authentication token not found",
          code: "TOKEN_REQUIRED",
        );
      }

      final response = await dioClient.get("/session-report/$sessionId", token: token);

      debugPrint('DataSource: Session report response status: ${response.statusCode}');
      debugPrint('DataSource: Session report response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final reportData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (reportData is Map<String, dynamic>) {
          debugPrint('✅ DataSource: Successfully parsed session report');
          return SessionReport.fromJson(reportData);
        } else {
          debugPrint('❌ DataSource: Invalid session report response format: ${reportData.runtimeType}');
          throw const ServerException(
            message: "Invalid session report response format",
            code: "INVALID_RESPONSE_FORMAT",
          );
        }
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data["message"] ?? "Failed to fetch session report"
            : "Failed to fetch session report";
        final errorCode = response.data is Map<String, dynamic>
            ? response.data["code"] ?? "FETCH_SESSION_REPORT_FAILED"
            : "FETCH_SESSION_REPORT_FAILED";

        debugPrint('❌ DataSource: Session report fetch failed: $errorMessage');
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } on ApiError catch (e) {
      debugPrint('❌ DataSource: API Error fetching session report: ${e.message}');
      _handleApiError(e, "FETCH_SESSION_REPORT_ERROR");
    } on FormatException catch (e) {
      debugPrint('❌ DataSource: Format/Parse error fetching session report: $e');
      throw ServerException(
        message: "Invalid response format from server: $e",
        code: "PARSE_ERROR",
      );
    } catch (e) {
      debugPrint('❌ DataSource: Unexpected error fetching session report: $e');
      if (e is ServerException ||
          e is AuthenticationException ||
          e is ValidationException ||
          e is NetworkException ||
          e is TimeoutException) {
        rethrow;
      }
      throw ServerException(
        message: "An unexpected error occurred while fetching session report: $e",
        code: "UNEXPECTED_FETCH_SESSION_REPORT_ERROR",
      );
    }
  }

  /// Handles API errors and converts them to appropriate exceptions
  Never _handleApiError(ApiError error, String defaultCode) {
    debugPrint('Handling API Error: ${error.message}, Status: ${error.statusCode}');

    if (error.statusCode != null) {
      switch (error.statusCode!) {
        case 400:
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
          }
          throw ServerException(message: error.message, code: "NOT_FOUND");
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

