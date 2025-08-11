import 'dart:convert' show jsonEncode;

import 'package:flutter/material.dart' show debugPrint;

import 'coupon.dart';
import 'participant_info.dart';

class VerificationResponse {
  final bool success;
  final String message;
  final ParticipantInfo? participant;
  final String? status;
  final List<Coupon>? coupons;

  const VerificationResponse({
    required this.success,
    required this.message,
    this.participant,
    this.status,
    this.coupons,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    debugPrint("verification response json: ${jsonEncode(json)}");

    // Updated: Consider multiple success messages
    final message = json['message']?.toString() ?? '';
    bool success =
        message.contains('successful') || message.contains('success');
    String? status;
    if (success) {
      status = json['attendance'] != null ? 'present' : 'Verified';
    } else {
      status = 'Not Verified';
    }

    try {
      return VerificationResponse(
        success: success,
        message: message,
        status: status,
        participant: json['participant'] != null
            ? ParticipantInfo.fromJson(json['participant'])
            : null,
        coupons: json['coupons'] != null
            ? (json['coupons'] as List)
                  .map((coupon) => Coupon.fromJson(coupon))
                  .toList()
            : null,
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse VerificationResponse from JSON: $e',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'participant': participant?.toJson(),
      'coupons': coupons?.map((coupon) => coupon.toJson()).toList(),
    };
  }
}
