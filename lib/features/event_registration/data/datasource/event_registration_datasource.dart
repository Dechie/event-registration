import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event_reg/core/constants/app_urls.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';

import '../../../landing/data/models/event.dart';
import '../models/event_reg_request.dart';
import '../models/event_reg_response.dart';
import '../models/event_registration.dart';
import '../models/participant_badge.dart';

abstract class EventRegistrationDataSource {
  Future<File> downloadParticipantPhoto(String photoPath);
  Future<List<Event>> fetchAvailableEvents();
  Future<ParticipantBadge> generateBadge(String eventId);
  Future<ParticipantBadge?> getBadge(String eventId);
  Future<Event> getEventDetails(String eventId);
  Future<List<Event>> getMyRegisteredEvents();
  Future<List<EventRegistration>> getMyRegistrations();
  Future<EventRegistration> getRegistrationStatus(String eventId);
  Future<EventRegistrationResponse> registerForEvent(
    EventRegistrationRequest request,
    String eventId,
  );
}

class EventRegistrationDataSourceImpl implements EventRegistrationDataSource {
  final DioClient dioClient;
  final UserDataService userDataService;

  EventRegistrationDataSourceImpl({
    required this.dioClient,
    required this.userDataService,
  });

  @override
  Future<File> downloadParticipantPhoto(String photoPath) async {
    // Check if the photoPath is a valid relative path
    if (photoPath.isEmpty) {
      throw Exception("Photo path is invalid.");
    }

    // Construct the full URL for the image
    final photoUrl = '${AppUrls.storageUrl}/$photoPath';
    debugPrint("🚀 Downloading photo from: $photoUrl");

    try {
      // Make a GET request with Dio, but specify the response type as bytes
      final response = await dioClient.dio.get(
        photoUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Get the temporary directory on the device
      final directory = await getTemporaryDirectory();
      final localPath = '${directory.path}/${photoPath.split('/').last}';

      // Create a file and write the downloaded bytes to it
      final file = File(localPath);
      await file.writeAsBytes(response.data);

      debugPrint("✅ Photo downloaded to: $localPath");

      return file;
    } on DioException catch (e) {
      throw ApiError("Failed to download image: ${e.message}");
    } catch (e) {
      throw ApiError("An unexpected error occurred: ${e.toString()}");
    }
  }

  @override
  Future<List<Event>> fetchAvailableEvents() async {
    final response = await dioClient.get('/fetch-events');

    final List<dynamic> eventsJson = response.data;

    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }

  @override
  Future<ParticipantBadge> generateBadge(String eventId) async {
    final token = await userDataService.getAuthToken();

    final response = await dioClient.post(
      '/events/$eventId/badge/generate',
      token: token,
    );

    debugPrint("badge image: ${response.data["photo"]}");
    File downloadedImage = await downloadParticipantPhoto(
      response.data["photo"],
    );
    response.data["downloaded_image"] = downloadedImage.path;

    return ParticipantBadge.fromJson(response.data);
  }

  @override
  Future<ParticipantBadge?> getBadge(String eventId) async {
    final token = await userDataService.getAuthToken();

    try {
      final response = await dioClient.get(
        '/events/$eventId/badge',
        token: token,
      );
      debugPrint("get badge hit");
      if (response.statusCode == 200) {
        for (var data in response.data) {
          debugPrint(data.runtimeType.toString());
        }
      }

      return ParticipantBadge.fromJson(response.data);
    } catch (e) {
      // Badge might not exist yet
      return null;
    }
  }

  @override
  Future<Event> getEventDetails(String eventId) async {
    final response = await dioClient.get('/get-event/$eventId');

    return Event.fromJson(response.data);
  }

  @override
  Future<List<Event>> getMyRegisteredEvents() async {
    final token = await userDataService.getAuthToken();

    final response = await dioClient.get('/my-events', token: token);

    final List<dynamic> eventsJson = response.data;

    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }

  @override
  Future<List<EventRegistration>> getMyRegistrations() async {
    final token = await userDataService.getAuthToken();

    final response = await dioClient.get('/my-registrations', token: token);

    final List<dynamic> registrationsJson = response.data;

    return registrationsJson
        .map((json) => EventRegistration.fromJson(json))
        .toList();
  }

  @override
  Future<EventRegistration> getRegistrationStatus(String eventId) async {
    final token = await userDataService.getAuthToken();

    // Fix: Use the correct endpoint from your Laravel backend
    debugPrint("this api hit");
    final response = await dioClient.get('/my-events/$eventId', token: token);

    // The Laravel endpoint returns the full event details with participant data
    // Extract the registration info from the participant data
    final participantData = response.data['participant'];

    return EventRegistration(
      id: participantData['id'].toString(),
      participantId: participantData['id'].toString(),
      eventId: eventId,
      registeredAt: DateTime.parse(response.data['event']['created_at']),
      status:
          participantData['is_approved'], // This maps to 'approved', 'pending', 'rejected'
      qrCode:
          participantData['badge_number'], // Use badge_number as QR code data
      badgeUrl: null, // We'll generate this locally
    );
  }

  @override
  Future<EventRegistrationResponse> registerForEvent(
    EventRegistrationRequest registratinRequest,
    String eventId,
  ) async {
    final token = await userDataService.getAuthToken();
    // No need to get userId here, as the backend will handle it

    // Create a new request without a participantId
    final modifiedRequest = EventRegistrationRequest(eventId: eventId);

    debugPrint("🚀 Request: POST /events/$eventId/participants");
    debugPrint(
      "📤 Data: ${jsonEncode(modifiedRequest.toJson())}",
    ); // This will now print {}

    try {
      final response = await dioClient.post(
        '/events/$eventId/participants',
        // Send an empty data object, or an object with other non-identifying info
        data: modifiedRequest.toJson(),
        token: token,
      );

      debugPrint("✅ Response: ${response.data}");

      return EventRegistrationResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      debugPrint("❌ Error registering for event: $e");
      debugPrint("Stack trace: $stackTrace");
      rethrow;
    }
  }

  // Response class

  // @override
  // Future<EventRegistrationResponse> registerForEvent(
  //   EventRegistrationRequest request,
  //   String eventId,
  // ) async {
  //   final token = await userDataService.getAuthToken();
  //   final userId = await userDataService.getUserId();
  //   request = request.copyWith(participantId: userId);

  //   debugPrint("request: ${jsonEncode(request.toJson())}");
  //   final response = await dioClient.post(
  //     '/events/$eventId/participants',
  //     data: request.toJson(),
  //     token: token,
  //   );

  //   return EventRegistrationResponse.fromJson(response.data);
  // }
}
