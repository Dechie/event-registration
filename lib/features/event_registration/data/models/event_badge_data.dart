import 'package:flutter/material.dart' show debugPrint;

class EventBadgeData {
  final String eventTitle;
  final String participantName;
  final String participantId;
  final String badgeNumber;
  final String? photoUrl;
  final String downloadedImagePath;
  final String organizationName;
  final DateTime eventDate;
  final String eventLocation;

  EventBadgeData({
    required this.eventTitle,
    required this.participantName,
    required this.participantId,
    required this.badgeNumber,
    this.photoUrl,
    this.downloadedImagePath = "",
    required this.organizationName,
    required this.eventDate,
    required this.eventLocation,
  });

  factory EventBadgeData.fromEventDetails(Map<String, dynamic> eventDetails) {
    final event = eventDetails['event'];
    final participant = eventDetails['participant'];
    debugPrint("photo: ${event['photo']}");
    

    return EventBadgeData(
      eventTitle: event['title'],
      participantName: participant['full_name'],
      participantId: participant['id'].toString(),
      badgeNumber: participant['badge_number'] ?? "12345",
      photoUrl: participant['photo'],
      organizationName: event['organization']['name'],
      eventDate: DateTime.parse(event['start_time']),
      eventLocation: event['location'],
      downloadedImagePath: eventDetails["downloaded_image_path"] ?? "",
    );
  }
}
