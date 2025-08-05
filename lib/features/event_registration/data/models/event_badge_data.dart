class EventBadgeData {
  final String eventTitle;
  final String participantName;
  final String participantId;
  final String badgeNumber;
  final String? photoUrl;
  final String organizationName;
  final DateTime eventDate;
  final String eventLocation;

  EventBadgeData({
    required this.eventTitle,
    required this.participantName,
    required this.participantId,
    required this.badgeNumber,
    this.photoUrl,
    required this.organizationName,
    required this.eventDate,
    required this.eventLocation,
  });

  factory EventBadgeData.fromEventDetails(Map<String, dynamic> eventDetails) {
    final event = eventDetails['event'];
    final participant = eventDetails['participant'];

    return EventBadgeData(
      eventTitle: event['title'],
      participantName: participant['full_name'],
      participantId: participant['id'].toString(),
      badgeNumber: participant['badge_number'] ?? "12345",
      photoUrl: participant['photo'],
      organizationName: event['organization']['name'],
      eventDate: DateTime.parse(event['start_time']),
      eventLocation: event['location'],
    );
  }
}
