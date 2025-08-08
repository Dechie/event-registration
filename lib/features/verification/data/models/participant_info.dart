// This should be added to: lib/features/verification/data/models/verification_response.dart
// (or create a separate file: lib/features/verification/data/models/participant_info.dart)

import 'package:flutter/material.dart' show debugPrint;

class ParticipantInfo {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? organization;
  final String? badgeNumber;
  final bool isVerified;
  final DateTime? verifiedAt;

  const ParticipantInfo({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.organization,
    this.badgeNumber,
    this.isVerified = false,
    this.verifiedAt,
  });

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) {
    try {
      return ParticipantInfo(
        id: (json['id'] ?? json['user_id'] ?? '').toString(),
        fullName: json['full_name'] ?? json['name'] ?? '',
        email: json['email'] ?? '',
        phoneNumber: json['phone_number'] ?? json['phone'],
        organization: json['organization'],
        badgeNumber: json['badge_number'],
        isVerified: json['is_verified'] ?? false,
        verifiedAt: json['verified_at'] != null
            ? DateTime.tryParse(json['verified_at'].toString())
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing ParticipantInfo: $e');
      throw FormatException('Failed to parse ParticipantInfo from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'organization': organization,
      'badge_number': badgeNumber,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ParticipantInfo(id: $id, fullName: $fullName, email: $email, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ParticipantInfo &&
        other.id == id &&
        other.fullName == fullName &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.organization == organization &&
        other.badgeNumber == badgeNumber &&
        other.isVerified == isVerified &&
        other.verifiedAt == verifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fullName.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        organization.hashCode ^
        badgeNumber.hashCode ^
        isVerified.hashCode ^
        verifiedAt.hashCode;
  }

  ParticipantInfo copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? organization,
    String? badgeNumber,
    bool? isVerified,
    DateTime? verifiedAt,
  }) {
    return ParticipantInfo(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      organization: organization ?? this.organization,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}