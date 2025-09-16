class Certificate {
  final String badgeNumber;
  final String participantName;
  final String eventTitle;
  final String organizationName;
  final DateTime issueDate;
  final String certificateUrl;
  final String status;
  final Map<String, dynamic>? metadata;

  const Certificate({
    required this.badgeNumber,
    required this.participantName,
    required this.eventTitle,
    required this.organizationName,
    required this.issueDate,
    required this.certificateUrl,
    required this.status,
    this.metadata,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      badgeNumber: json['badge_number'] ?? '',
      participantName: json['participant_name'] ?? '',
      eventTitle: json['event_title'] ?? '',
      organizationName: json['organization_name'] ?? '',
      issueDate: DateTime.tryParse(json['issue_date'] ?? '') ?? DateTime.now(),
      certificateUrl: json['certificate_url'] ?? '',
      status: json['status'] ?? 'available',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badge_number': badgeNumber,
      'participant_name': participantName,
      'event_title': eventTitle,
      'organization_name': organizationName,
      'issue_date': issueDate.toIso8601String(),
      'certificate_url': certificateUrl,
      'status': status,
      'metadata': metadata,
    };
  }

  Certificate copyWith({
    String? badgeNumber,
    String? participantName,
    String? eventTitle,
    String? organizationName,
    DateTime? issueDate,
    String? certificateUrl,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return Certificate(
      badgeNumber: badgeNumber ?? this.badgeNumber,
      participantName: participantName ?? this.participantName,
      eventTitle: eventTitle ?? this.eventTitle,
      organizationName: organizationName ?? this.organizationName,
      issueDate: issueDate ?? this.issueDate,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Certificate(badgeNumber: $badgeNumber, participantName: $participantName, eventTitle: $eventTitle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Certificate && other.badgeNumber == badgeNumber;
  }

  @override
  int get hashCode => badgeNumber.hashCode;
}
