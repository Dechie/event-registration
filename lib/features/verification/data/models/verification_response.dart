import 'dart:convert';

import 'package:event_reg/features/verification/data/models/coupon.dart';
import 'package:flutter/material.dart' show debugPrint;

import 'participant_info.dart';

class VerificationResponse {
  final bool success;
  final String message;
  final ParticipantInfo? participant;
  final String? status;
  final List<Coupon>? coupons; // Add this line

  const VerificationResponse({
    required this.success,
    required this.message,
    this.participant,
    this.status,
    this.coupons, // Add this line
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
        coupons: json['coupons'] != null // Add this block
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
      'coupons': coupons?.map((coupon) => coupon.toJson()).toList(), // Add this line
    };
  }
}

// Add this new Coupon model at the end of the file
