// lib/features/registration/data/datasources/registration_remote_datasource.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/shared/models/participant.dart';
import 'package:event_reg/features/dashboard/data/models/session.dart';
import 'package:event_reg/features/registration/data/models/registration_response.dart';
import 'package:event_reg/features/registration/data/models/registration_result.dart';

abstract class RegistrationRemoteDataSource {
  Future<void> cancelRegistration(String participantId);
  Future<List<Participant>> getAllParticipants();
  Future<List<Session>> getAvailableSessions();
  Future<List<String>> getIndustries();
  Future<Map<String, List<String>>>
  getLocationData(); // regions, cities, woredas
  Future<List<String>> getOccupations();
  Future getParticipantByEmail(String email);
  Future<RegistrationResponse> getRegistrationStatus(String email);
  //Future<RegistrationResponse> registerParticipant(RegistrationRequest request);
  Future<RegistrationResponse> registerParticipant(Participant participant);
  Future<void> resendOtp(String email);
  Future<void> sendOtp(String email);

  Future<Participant> updateParticipantInfo(
    String participantId,
    Map<String, dynamic> data,
  );

  Future<String> uploadPhoto(File photo, String participantId);
  Future<bool> verifyOtp(String email, String otp);
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  final DioClient dioClient;

  RegistrationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<void> cancelRegistration(String participantId) async {
    try {
      final response = await dioClient.delete(
        '/registration/participant/$participantId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to cancel registration',
          code: 'CANCEL_REGISTRATION_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'CANCEL_REGISTRATION_ERROR');
    }
  }

  @override
  Future<List<Participant>> getAllParticipants() async {
    return [];
  }

  @override
  Future<List<Session>> getAvailableSessions() async {
    try {
      final response = await dioClient.get('/registration/sessions');

      if (response.statusCode == 200) {
        final List<dynamic> sessionsJson = response.data['data'] ?? [];
        return sessionsJson.map((json) => Session.fromJson(json)).toList();
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to get available sessions',
          code: 'GET_SESSIONS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'GET_SESSIONS_ERROR');
    }
  }

  @override
  Future<List<String>> getIndustries() async {
    try {
      final response = await dioClient.get('/registration/data/industries');

      if (response.statusCode == 200) {
        final List<dynamic> industriesJson = response.data['data'] ?? [];
        return industriesJson.map((e) => e.toString()).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get industries',
          code: 'GET_INDUSTRIES_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'GET_INDUSTRIES_ERROR');
    }
  }

  @override
  Future<Map<String, List<String>>> getLocationData() async {
    try {
      final response = await dioClient.get('/registration/data/locations');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        return {
          'regions':
              (data['regions'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          'cities':
              (data['cities'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          'woredas':
              (data['woredas'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        };
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get location data',
          code: 'GET_LOCATIONS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'GET_LOCATIONS_ERROR');
    }
  }

  @override
  Future<List<String>> getOccupations() async {
    try {
      final response = await dioClient.get('/registration/data/occupations');

      if (response.statusCode == 200) {
        final List<dynamic> occupationsJson = response.data['data'] ?? [];
        return occupationsJson.map((e) => e.toString()).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get occupations',
          code: 'GET_OCCUPATIONS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'GET_OCCUPATIONS_ERROR');
    }
  }

  @override
  Future getParticipantByEmail(String email) async {}

  @override
  Future<RegistrationResponse> getRegistrationStatus(String email) async {
    try {
      final response = await dioClient.get(
        '/registration/status',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        return RegistrationResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to get registration status',
          code: 'GET_STATUS_ERROR',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException(
          message: 'No registration found for this email',
          code: 'REGISTRATION_NOT_FOUND',
        );
      }
      throw _handleDioException(e, 'GET_STATUS_ERROR');
    }
  }

  @override
  Future<RegistrationResponse> registerParticipant(
    Participant participant,
  ) async {
    return RegistrationResponse(
      id: "",
      message: "",
      participant: Participant(
        id: "",
        fullName: "fullName",
        email: "email",
        phoneNumber: "phoneNumber",
        occupation: "occupation",
        organization: "organization",
        industry: "industry",
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> resendOtp(String email) async {
    try {
      final response = await dioClient.post(
        '/registration/resend-otp',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to resend OTP',
          code: 'RESEND_OTP_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw ServerException(
          message:
              'Too many OTP requests. Please wait before requesting again.',
          code: 'OTP_RATE_LIMIT',
        );
      }
      throw _handleDioException(e, 'RESEND_OTP_ERROR');
    }
  }

  // @override
  // Future<RegistrationResponse> registerParticipant(
  //   RegistrationRequest request,
  // ) async {
  //   try {
  //     final response = await dioClient.post(
  //       '/registration/register',
  //       data: request.toJson(),
  //     );

  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       return RegistrationResponse.fromJson(response.data['data']);
  //     } else {
  //       throw ServerException(
  //         message: response.data['message'] ?? 'Registration failed',
  //         code: 'REGISTRATION_FAILED',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     throw _handleDioException(e, 'REGISTRATION_ERROR');
  //   }
  // }

  @override
  Future<void> sendOtp(String email) async {
    try {
      final response = await dioClient.post(
        '/registration/resend-otp',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to resend OTP',
          code: 'RESEND_OTP_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw ServerException(
          message:
              'Too many OTP requests. Please wait before requesting again.',
          code: 'OTP_RATE_LIMIT',
        );
      }
      throw _handleDioException(e, 'RESEND_OTP_ERROR');
    }
  }

  @override
  Future<Participant> updateParticipantInfo(
    String participantId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dioClient.put(
        '/registration/participant/$participantId',
        data: data,
      );

      if (response.statusCode == 200) {
        return Participant.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to update participant info',
          code: 'UPDATE_PARTICIPANT_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'UPDATE_PARTICIPANT_ERROR');
    }
  }

  @override
  Future<String> uploadPhoto(File photo, String participantId) async {
    try {
      final fileName = photo.path.split('/').last;
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
        'participant_id': participantId,
      });

      final response = await dioClient.post(
        '/registration/upload-photo',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data']['photo_url'] as String;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Photo upload failed',
          code: 'PHOTO_UPLOAD_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout) {
        throw TimeoutException(
          message: 'Photo upload timed out. Please try again.',
          code: 'UPLOAD_TIMEOUT',
        );
      }
      throw _handleDioException(e, 'PHOTO_UPLOAD_ERROR');
    }
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await dioClient.post(
        '/registration/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return true;
        
        //return RegistrationResult.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'OTP verification failed',
          code: 'OTP_VERIFICATION_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          message: 'Invalid or expired OTP',
          code: 'INVALID_OTP',
        );
      }
      throw _handleDioException(e, 'OTP_VERIFICATION_ERROR');
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
        case 401:
          return AuthenticationException(
            message: responseData['message'] ?? 'Authentication required',
            code: 'AUTHENTICATION_ERROR',
          );
        case 403:
          return AuthorizationException(
            message: responseData['message'] ?? 'Access denied',
            code: 'AUTHORIZATION_ERROR',
          );
        case 404:
          return ServerException(
            message: responseData['message'] ?? 'Resource not found',
            code: 'NOT_FOUND',
          );
        case 409:
          return ServerException(
            message: responseData['message'] ?? 'Email already registered',
            code: 'EMAIL_ALREADY_EXISTS',
          );
        case 422:
          final errors = responseData['errors'] as Map<String, dynamic>?;
          return ValidationException(
            message: responseData['message'] ?? 'Validation failed',
            code: 'VALIDATION_ERROR',
            errors: errors?.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            ),
          );
        case 429:
          return ServerException(
            message: responseData['message'] ?? 'Too many requests',
            code: 'RATE_LIMIT_ERROR',
          );
        case 500:
          return ServerException(
            message: responseData['message'] ?? 'Internal server error',
            code: 'SERVER_ERROR',
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
