import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:flutter/material.dart' show debugPrint;

class LoginResponse {
  final String token;
  final User user;
  final String message;

  LoginResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 Parsing LoginResponse from: $json');

      final token = json['token'];
      final userData = json['user'];

      debugPrint('🔍 Token: $token');
      debugPrint('🔍 User data: $userData');

      if (token == null || token.isEmpty) {
        throw FormatException('Token is null or empty');
      }

      if (userData == null || userData is! Map<String, dynamic>) {
        throw FormatException('User data is null or not a Map');
      }

      final user = User.fromJson(userData);
      debugPrint('✅ Successfully parsed User: ${user.toString()}');

      return LoginResponse(
        token: token,
        user: user,
        message: json['message'] ?? 'Login successful',
      );
    } catch (e) {
      debugPrint('❌ Error in LoginResponse.fromJson: $e');
      debugPrint('❌ JSON was: $json');
      rethrow;
    }
  }

  LoginResponse copyWith({
    String? token,
    String? tokenType,
    User? user,
    String? message,
    DateTime? expiresAt,
    String? refreshToken,
  }) {
    return LoginResponse(
      token: token ?? this.token,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson(), 'message': message};
  }
}
