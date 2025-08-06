import 'package:flutter/foundation.dart';

class ParticipantBadge {
  final String id;
  final String participantId;
  final String eventId;
  final String qrCode;
  final String? badgeImageUrl;
  final DateTime generatedAt;
  final String? downloadedImagePath;

  ParticipantBadge({
    required this.id,
    required this.participantId,
    required this.eventId,
    required this.qrCode,
    this.badgeImageUrl,
    this.downloadedImagePath,
    required this.generatedAt,
  });

  factory ParticipantBadge.fromJson(Map<String, dynamic> json) {
    var downloadedImagePath = json["downloaded_image"] as String;
    debugPrint(
      "downloaded image path at fromJson method: $downloadedImagePath",
    );
    return ParticipantBadge(
      id: json['id'].toString(),
      participantId: json['participant_id'].toString(),
      eventId: json['event_id'].toString(),
      qrCode: json['qr_code'],
      badgeImageUrl: json['badge_image_url'],
      downloadedImagePath: json["downloaded_image"],
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_id': participantId,
      'event_id': eventId,
      'qr_code': qrCode,
      'badge_image_url': badgeImageUrl,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
