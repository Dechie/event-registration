// lib/features/event_registration/data/models/event_registration.dart
import 'package:event_reg/features/event_registration/data/models/participant_badge.dart';

class EventRegistration {
  final String id;
  final String participantId;
  final String eventId;
  final DateTime registeredAt;
  final String status; // Added status field
  final String? qrCode; // Added QR code field
  final String? badgeUrl; // Added badge URL field
  final ParticipantBadge? badge;

  EventRegistration({
    required this.id,
    required this.participantId,
    required this.eventId,
    required this.registeredAt,
    required this.status,
    this.qrCode,
    this.badgeUrl,
    required this.badge,
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
      badge: ParticipantBadge(
        id: "1234",
        participantId: "1",
        qrCode: 'DUMMY_QR_CODE',
        eventId: '12345', // Replace with participant ID
        //organization: 'Example Corp', // Replace with organization name
        generatedAt: DateTime.now(),
      ),
    );
  }

  bool get canGenerateBadge => isApproved && qrCode != null;

  bool get isApproved => status.toLowerCase() == 'approved';
  // Helper methods
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

// lib/features/event_registration/data/models/participant_badge.dart
