// lib/features/verification/data/models/verification_response.dart

import 'dart:convert';

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
      throw FormatException('Failed to parse ParticipantInfo from JSON: $e');
    }
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
}

class VerificationResponse {
  final bool success;
  final String message;
  final ParticipantInfo? participant;
  final String? status;

  const VerificationResponse({
    required this.success,
    required this.message,
    this.participant,
    this.status,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    debugPrint("verification response json: ${jsonEncode(json)}");
    bool success = json["message"] == "Security check successful.";
    String status = success ? "Verified" : "Not Verified";
    try {
      return VerificationResponse(
        success: success,
        message: json['message'] ?? '',
        status: status,
        participant: json['participant'] != null
            ? ParticipantInfo.fromJson(json['participant'])
            : null,
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse VerificationResponse from JSON: $e',
      );
    }
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        status.hashCode ^
        participant.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationResponse &&
        other.success == success &&
        other.message == message &&
        other.status == status &&
        other.participant == participant;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'participant': participant?.toJson(),
    };
  }

  @override
  String toString() {
    return 'VerificationResponse(success: $success, message: $message, status: $status, participant: $participant)';
  }
}
