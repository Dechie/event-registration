class EventRegistrationRequest {
  final String participantId;
  final String eventId;

  EventRegistrationRequest({
    required this.participantId,
    required this.eventId,
  });

  Map<String, dynamic> toJson() {
    return {
      'participant_id': participantId,
    };
  }
}