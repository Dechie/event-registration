class Coupon {
  final String id;
  final String title;
  final String description;
  final String? value;
  final bool isRedeemed;
  final DateTime? redeemedAt;
  final String? eventSessionId;

  const Coupon({
    required this.id,
    required this.title,
    required this.description,
    this.value,
    this.isRedeemed = false,
    this.redeemedAt,
    this.eventSessionId,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      value: json['value']?.toString(),
      isRedeemed: json['is_redeemed'] ?? false,
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.tryParse(json['redeemed_at'].toString())
          : null,
      eventSessionId: json['event_session_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'value': value,
      'is_redeemed': isRedeemed,
      'redeemed_at': redeemedAt?.toIso8601String(),
      'event_session_id': eventSessionId,
    };
  }
}