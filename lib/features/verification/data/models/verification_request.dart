// lib/features/verification/data/models/verification_request.dart

class VerificationRequest {
  final String type; // 'attendance', 'coupon', 'security', or 'info'
  final String badgeNumber;
  final String? eventSessionId; // required if type is 'attendance'
  final String? couponId; // required if type is 'coupon'

  const VerificationRequest({
    required this.type,
    required this.badgeNumber,
    this.eventSessionId,
    this.couponId,
  });

  // Factory constructor for security check
  factory VerificationRequest.security({required String badgeNumber}) {
    return VerificationRequest(
      type: 'security',
      badgeNumber: badgeNumber,
    );
  }

  // Factory constructor for attendance
  factory VerificationRequest.attendance({
    required String badgeNumber,
    required String eventSessionId,
  }) {
    return VerificationRequest(
      type: 'attendance',
      badgeNumber: badgeNumber,
      eventSessionId: eventSessionId,
    );
  }

  // Factory constructor for coupon
  factory VerificationRequest.coupon({
    required String badgeNumber,
    required String couponId,
  }) {
    return VerificationRequest(
      type: 'coupon',
      badgeNumber: badgeNumber,
      couponId: couponId,
    );
  }

  // Factory constructor for info/participant details
  factory VerificationRequest.info({required String badgeNumber}) {
    return VerificationRequest(
      type: 'info',
      badgeNumber: badgeNumber,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'badge_number': badgeNumber,
    };

    // Add conditional fields based on type
    if (type == 'attendance' && eventSessionId != null) {
      json['eventsession_id'] = int.tryParse(eventSessionId!) ?? 1;
    }

    if (type == 'coupon' && couponId != null) {
      json['coupon_id'] = int.tryParse(couponId!) ?? 1;
    }

    return json;
  }

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      type: json['type'] ?? 'security',
      badgeNumber: json['badge_number'] ?? '',
      eventSessionId: json['eventsession_id']?.toString(),
      couponId: json['coupon_id']?.toString(),
    );
  }

  @override
  String toString() {
    return 'VerificationRequest(type: $type, badgeNumber: $badgeNumber, eventSessionId: $eventSessionId, couponId: $couponId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationRequest &&
        other.type == type &&
        other.badgeNumber == badgeNumber &&
        other.eventSessionId == eventSessionId &&
        other.couponId == couponId;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        badgeNumber.hashCode ^
        eventSessionId.hashCode ^
        couponId.hashCode;
  }

  VerificationRequest copyWith({
    String? type,
    String? badgeNumber,
    String? eventSessionId,
    String? couponId,
  }) {
    return VerificationRequest(
      type: type ?? this.type,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      eventSessionId: eventSessionId ?? this.eventSessionId,
      couponId: couponId ?? this.couponId,
    );
  }
}