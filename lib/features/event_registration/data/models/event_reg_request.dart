class EventRegistrationRequest {
  // Remove the participantId from here
  // final String? participantId;

  final String eventId;

  EventRegistrationRequest({
    // Remove participantId from the constructor
    required this.eventId,
  });

  // The toJson method will now return an empty map or just the eventId if needed,
  // but for your specific backend endpoint, an empty body is likely what's needed
  Map<String, dynamic> toJson() {
    return {}; // The backend expects an empty body for this action
  }
}