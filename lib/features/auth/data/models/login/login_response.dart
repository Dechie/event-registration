// Fixed login_response.dart
import 'dart:convert';

import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:flutter/material.dart' show debugPrint;

class LoginResponse {
  final String id;
  final String message;
  final String token;
  final User user;

  LoginResponse({
    required this.id,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint("LoginResponse.fromJson() - Raw JSON: ${jsonEncode(json)}");

      final userJson = Map<String, dynamic>.from(json['user']);

      // Handle role properly - extract from the role object if it exists
      if (json.containsKey('role') && json['role'] is Map<String, dynamic>) {
        final roleMap = json['role'] as Map<String, dynamic>;
        userJson['role'] = roleMap['name'] ?? 'participant';
        debugPrint("Role extracted from role object: ${userJson['role']}");
      }

      // Set profile status from root level
      userJson['has_profile'] = json['has_profile'] ?? false;
      userJson['profile_required'] = json['profile_required'] ?? false;

      debugPrint("Final userJson for User.fromJson(): ${jsonEncode(userJson)}");

      return LoginResponse(
        id: (json['id'] ?? json['user']?['id'] ?? "").toString(),
        message: json['message'] ?? "Login successful",
        token: json['token'] ?? "no-token",
        user: User.fromJson(userJson),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in LoginResponse.fromJson: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON was: ${jsonEncode(json)}');
      rethrow;
    }
  }

  LoginResponse copyWithForceUserRole({required String role}) {
    return LoginResponse(
      id: id,
      message: message,
      token: token,
      user: user.copyWith(role: role),
    );
  }
}
