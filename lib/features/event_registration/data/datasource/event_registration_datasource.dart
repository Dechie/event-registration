// lib/features/event_registration/data/datasource/event_registration_datasource.dart
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/constants/app_urls.dart';
import 'package:event_reg/core/services/user_data_service.dart';

import '../../../landing/data/models/event.dart';
import '../models/event_reg_request.dart';
import '../models/event_reg_response.dart';

abstract class EventRegistrationDataSource {
  Future<List<Event>> fetchAvailableEvents();
  Future<Event> getEventDetails(String eventId);
  Future<EventRegistrationResponse> registerForEvent(EventRegistrationRequest request, String eventId);
  Future<List<Event>> getMyRegisteredEvents();
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
  Future<Event> getEventDetails(String eventId) async {
    final response = await dioClient.get('/get-event/$eventId');
    return Event.fromJson(response.data);
  }

  @override
  Future<EventRegistrationResponse> registerForEvent(
    EventRegistrationRequest request, 
    String eventId
  ) async {
    final token = await userDataService.getAuthToken();
    
    final response = await dioClient.post(
      '/events/$eventId/participants',
      data: request.toJson(),
      token: token,
    );
    
    return EventRegistrationResponse.fromJson(response.data);
  }

  @override
  Future<List<Event>> getMyRegisteredEvents() async {
    final token = await userDataService.getAuthToken();
    
    final response = await dioClient.get(
      '/my-events',
      token: token,
    );
    
    final List<dynamic> eventsJson = response.data;
    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }
}