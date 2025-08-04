class ParticipantBadge {
  final String id;
  final String participantId;
  final String eventId;
  final String qrCode;
  final String? badgeImageUrl;
  final DateTime generatedAt;

  ParticipantBadge({
    required this.id,
    required this.participantId,
    required this.eventId,
    required this.qrCode,
    this.badgeImageUrl,
    required this.generatedAt, 
  });

  factory ParticipantBadge.fromJson(Map<String, dynamic> json) {
    return ParticipantBadge(
      id: json['id'].toString(),
      participantId: json['participant_id'].toString(),
      eventId: json['event_id'].toString(),
      qrCode: json['qr_code'],
      badgeImageUrl: json['badge_image_url'],
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