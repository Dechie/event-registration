class EventRegistration {
  final String id;
  final String participantId;
  final String eventId;
  final DateTime registeredAt;

  EventRegistration({
    required this.id,
    required this.participantId,
    required this.eventId,
    required this.registeredAt,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'].toString(),
      participantId: json['participant_id'].toString(),
      eventId: json['event_id'].toString(),
      registeredAt: DateTime.parse(json['created_at']),
    );
  }
}