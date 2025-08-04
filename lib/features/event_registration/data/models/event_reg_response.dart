import 'event_registration.dart';

class EventRegistrationResponse {
  final String message;
  final EventRegistration? registration;

  EventRegistrationResponse({
    required this.message,
    this.registration,
  });

  factory EventRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return EventRegistrationResponse(
      message: json['message'] ?? 'Registration successful',
      registration: json['registration'] != null 
          ? EventRegistration.fromJson(json['registration'])
          : null,
    );
  }
}