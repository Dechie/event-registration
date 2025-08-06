class VerificationRequest {
  final String badgeNumber;

  const VerificationRequest({
    required this.badgeNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'badge_number': badgeNumber,
    };
  }

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      badgeNumber: json['badge_number'] ?? '',
    );
  }

  @override
  String toString() {
    return 'VerificationRequest(badgeNumber: $badgeNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationRequest && other.badgeNumber == badgeNumber;
  }

  @override
  int get hashCode => badgeNumber.hashCode;
}