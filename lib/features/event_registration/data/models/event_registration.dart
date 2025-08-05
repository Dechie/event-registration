class EventRegistration {
  final String id;
  final String participantId;
  final String eventId;
  final DateTime registeredAt;
  final String status;
  final String? qrCode;
  final String? badgeUrl;

  EventRegistration({
    required this.id,
    required this.participantId,
    required this.eventId,
    required this.registeredAt,
    required this.status,
    this.qrCode,
    this.badgeUrl,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'].toString(),
      participantId: json['participant_id'].toString(),
      eventId: json['event_id'].toString(),
      registeredAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'pending', // pending, approved, rejected
      qrCode: json['qr_code'],
      badgeUrl: json['badge_url'],
    );
  }

  // Add badge number property
  String? get badgeNumber =>
      qrCode; // Since we're using badge_number as QR data
  bool get canGenerateBadge => isApproved && qrCode != null;
  // Update the status checking methods to match Laravel's enum values
  bool get isApproved => status.toLowerCase() == 'approved';

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_id': participantId,
      'event_id': eventId,
      'created_at': registeredAt.toIso8601String(),
      'status': status,
      'qr_code': qrCode,
      'badge_url': badgeUrl,
    };
  }
}
