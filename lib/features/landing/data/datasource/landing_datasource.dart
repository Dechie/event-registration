// lib/features/landing/data/datasource/landing_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/dashboard/data/models/event.dart';

import '../../../attendance/data/models/session.dart';

abstract class LandingRemoteDataSource {
  Future<Map<String, dynamic>> getContactInfo();
  Future<List<Map<String, dynamic>>> getEventHighlights();
  Future<Event> getEventInfo();
  Future<Map<String, dynamic>> getEventSchedule();
  Future<Map<String, dynamic>> getEventStats();
  Future<List<Session>> getFeaturedSessions();
  Future<List<Map<String, dynamic>>> getSpeakers();
  Future<List<Map<String, dynamic>>> getSponsors();
  Future<Map<String, dynamic>> getVenueInfo();
}

class LandingRemoteDataSourceImpl implements LandingRemoteDataSource {
  final DioClient dioClient;

  LandingRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> getContactInfo() async {
    try {
      final response = await dioClient.get('/public/contact');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to get contact information',
          code: 'CONTACT_INFO_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'CONTACT_INFO_ERROR');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEventHighlights() async {
    try {
      final response = await dioClient.get('/public/event/highlights');

      if (response.statusCode == 200) {
        final List<dynamic> highlightsJson = response.data['data'] ?? [];
        return highlightsJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get event highlights',
          code: 'EVENT_HIGHLIGHTS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'EVENT_HIGHLIGHTS_ERROR');
    }
  }

  @override
  Future<Event> getEventInfo() async {
    try {
      final response = await dioClient.get('/public/event');

      if (response.statusCode == 200) {
        return Event.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to get event information',
          code: 'EVENT_INFO_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'EVENT_INFO_ERROR');
    }
  }

  @override
  Future<Map<String, dynamic>> getEventSchedule() async {
    try {
      final response = await dioClient.get('/public/event/schedule');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get event schedule',
          code: 'EVENT_SCHEDULE_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'EVENT_SCHEDULE_ERROR');
    }
  }

  @override
  Future<Map<String, dynamic>> getEventStats() async {
    try {
      final response = await dioClient.get('/public/event/stats');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get event stats',
          code: 'EVENT_STATS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'EVENT_STATS_ERROR');
    }
  }

  @override
  Future<List<Session>> getFeaturedSessions() async {
    try {
      final response = await dioClient.get('/public/sessions/featured');

      if (response.statusCode == 200) {
        final List<dynamic> sessionsJson = response.data['data'] ?? [];
        return sessionsJson.map((json) => Session.fromJson(json)).toList();
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to get featured sessions',
          code: 'FEATURED_SESSIONS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'FEATURED_SESSIONS_ERROR');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSpeakers() async {
    try {
      final response = await dioClient.get('/public/speakers');

      if (response.statusCode == 200) {
        final List<dynamic> speakersJson = response.data['data'] ?? [];
        return speakersJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get speakers',
          code: 'SPEAKERS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'SPEAKERS_ERROR');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSponsors() async {
    try {
      final response = await dioClient.get('/public/sponsors');

      if (response.statusCode == 200) {
        final List<dynamic> sponsorsJson = response.data['data'] ?? [];
        return sponsorsJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get sponsors',
          code: 'SPONSORS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'SPONSORS_ERROR');
    }
  }

  @override
  Future<Map<String, dynamic>> getVenueInfo() async {
    try {
      final response = await dioClient.get('/public/venue');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to get venue information',
          code: 'VENUE_INFO_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'VENUE_INFO_ERROR');
    }
  }

  // Helper method to handle DioExceptions consistently
  AppException _handleDioException(DioException e, String defaultCode) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(
        message: 'Connection timeout. Please check your internet connection.',
        code: 'TIMEOUT_ERROR',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'No internet connection. Please check your network.',
        code: 'NETWORK_ERROR',
      );
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      switch (statusCode) {
        case 400:
          return ServerException(
            message: responseData['message'] ?? 'Bad request',
            code: 'BAD_REQUEST',
          );
        case 404:
          return ServerException(
            message: responseData['message'] ?? 'Resource not found',
            code: 'NOT_FOUND',
          );
        case 500:
          return ServerException(
            message: responseData['message'] ?? 'Internal server error',
            code: 'SERVER_ERROR',
          );
        case 503:
          return ServerException(
            message: responseData['message'] ?? 'Service unavailable',
            code: 'SERVICE_UNAVAILABLE',
          );
        default:
          return ServerException(
            message: responseData['message'] ?? 'Server error occurred',
            code: defaultCode,
          );
      }
    } else {
      return ServerException(
        message: 'Unknown server error occurred',
        code: defaultCode,
      );
    }
  }
}
