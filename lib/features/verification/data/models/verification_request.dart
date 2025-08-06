// lib/features/verification/data/models/verification_request.dart

class VerificationRequest {
  final String type; // 'attendance', 'coupon', or 'security'
  final String participantId;
  final String? eventSessionId; // required if type is 'attendance'
  final String? couponId; // required if type is 'coupon'
  final String? badgeNumber; // for backwards compatibility

  const VerificationRequest({
    required this.type,
    required this.participantId,
    this.eventSessionId,
    this.couponId,
    this.badgeNumber,
  });

  // Factory constructor for security check (backwards compatibility)
  factory VerificationRequest.security({required String badgeNumber}) {
    return VerificationRequest(
      type: 'security',
      participantId: badgeNumber, // Use badge number as participant ID for security
      badgeNumber: badgeNumber,
    );
  }

  // Factory constructor for attendance
  factory VerificationRequest.attendance({
    required String participantId,
    required String eventSessionId,
  }) {
    return VerificationRequest(
      type: 'attendance',
      participantId: participantId,
      eventSessionId: eventSessionId,
    );
  }

  // Factory constructor for coupon
  factory VerificationRequest.coupon({
    required String participantId,
    required String couponId,
  }) {
    return VerificationRequest(
      type: 'coupon',
      participantId: participantId,
      couponId: couponId,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'participant_id': participantId,
    };

    // Add conditional fields based on type
    if (type == 'attendance' && eventSessionId != null) {
      json['eventsession_id'] = eventSessionId;
    }

    if (type == 'coupon' && couponId != null) {
      json['coupon_id'] = couponId;
    }

    // For backwards compatibility with security checks
    if (badgeNumber != null) {
      json['badge_number'] = badgeNumber;
    }

    return json;
  }

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      type: json['type'] ?? 'security',
      participantId: json['participant_id'] ?? '',
      eventSessionId: json['eventsession_id'],
      couponId: json['coupon_id'],
      badgeNumber: json['badge_number'],
    );
  }

  @override
  String toString() {
    return 'VerificationRequest(type: $type, participantId: $participantId, eventSessionId: $eventSessionId, couponId: $couponId, badgeNumber: $badgeNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationRequest &&
        other.type == type &&
        other.participantId == participantId &&
        other.eventSessionId == eventSessionId &&
        other.couponId == couponId &&
        other.badgeNumber == badgeNumber;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        participantId.hashCode ^
        eventSessionId.hashCode ^
        couponId.hashCode ^
        badgeNumber.hashCode;
  }

  VerificationRequest copyWith({
    String? type,
    String? participantId,
    String? eventSessionId,
    String? couponId,
    String? badgeNumber,
  }) {
    return VerificationRequest(
      type: type ?? this.type,
      participantId: participantId ?? this.participantId,
      eventSessionId: eventSessionId ?? this.eventSessionId,
      couponId: couponId ?? this.couponId,
      badgeNumber: badgeNumber ?? this.badgeNumber,
    );
  }
}