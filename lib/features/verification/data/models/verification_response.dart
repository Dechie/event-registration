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

    final message = json['message']?.toString() ?? '';

    // Check for explicit success field or successful messages
    bool success =
        json['success'] == true ||
        json['status'] == 'success' ||
        message.contains('successful') ||
        message.contains('Check-in successful');

    // Handle specific error cases from backend
    if (message.contains('not found') ||
        message.contains('not approved') ||
        message.contains('Already checked in') ||
        message.contains('No active attendance round') ||
        message.contains('Usage limit reached') ||
        message.contains('Coupon is inactive')) {
      success = false;
    }

    String? status;
    if (success) {
      // Extract status from attendance response
      if (json['attendance'] != null && json['attendance']['status'] != null) {
        status = json['attendance']['status']; // 'present' or 'late'
      } else {
        status = 'Verified';
      }
    } else {
      status = 'Failed';
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
