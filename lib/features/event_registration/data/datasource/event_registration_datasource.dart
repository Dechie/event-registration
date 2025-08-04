import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';

import '../../../landing/data/models/event.dart';
import '../models/event_reg_request.dart';
import '../models/event_reg_response.dart';
import '../models/event_registration.dart';
import '../models/participant_badge.dart';

abstract class EventRegistrationDataSource {
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

    final response = await dioClient.get('/my-events/$eventId', token: token);

    return EventRegistration.fromJson(response.data['registration']);
  }

  @override
  Future<EventRegistrationResponse> registerForEvent(
    EventRegistrationRequest request,
    String eventId,
  ) async {
    final token = await userDataService.getAuthToken();

    final response = await dioClient.post(
      '/events/$eventId/participants',
      data: request.toJson(),
      token: token,
    );

    return EventRegistrationResponse.fromJson(response.data);
  }
}
