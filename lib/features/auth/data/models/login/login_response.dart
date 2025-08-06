import 'dart:convert';

import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:flutter/material.dart' show debugPrint;

// class LoginResponse {
//   final String id;
//   final String token;
//   final User user;
//   final String message;

//   LoginResponse({
//     required this.id,
//     required this.token,
//     required this.user,
//     required this.message,
//   });

//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     try {
//       debugPrint('🔍 Parsing LoginResponse from: $json');

//       final id = "${json["id"]}";
//       final token = json['token'];
//       final userData = json['user'];

//       debugPrint('🔍 Token: $token');
//       debugPrint('🔍 User data: $userData');

//       if (token == null || token.isEmpty) {
//         throw FormatException('Token is null or empty');
//       }

//       if (userData == null || userData is! Map<String, dynamic>) {
//         throw FormatException('User data is null or not a Map');
//       }

//       final user = User.fromJson(userData);
//       debugPrint('✅ Successfully parsed User: ${user.toString()}');

//       return LoginResponse(
//         id: id,
//         token: token,
//         user: user,
//         message: json['message'] ?? 'Login successful',
//       );
//     } catch (e) {
//       debugPrint('❌ Error in LoginResponse.fromJson: $e');
//       debugPrint('❌ JSON was: $json');
//       rethrow;
//     }
//   }

//   LoginResponse copyWith({
//     String? token,
//     String? tokenType,
//     User? user,
//     String? message,
//     DateTime? expiresAt,
//     String? refreshToken,
//     String? id,
//   }) {
//     return LoginResponse(
//       id: id ?? this.id,
//       token: token ?? this.token,
//       user: user ?? this.user,
//       message: message ?? this.message,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'token': token, 'user': user.toJson(), 'message': message};
//   }
// }
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
    final userJson = Map<String, dynamic>.from(json['user']);
    userJson['role'] = json['role'] ?? json['user_type'] ?? 'participant';
    userJson['has_profile'] = json['has_profile'];

    for (var entry in userJson.entries) {
      if (entry.key == "user") {
        debugPrint("<${entry.key}>");
        for (var entryU in entry.value.entries) {
          String val = "";
          if (entryU.value == null) {
            val = "null";
          } else if (entryU.value == "") {
            val = "empt";
          } else if (entryU.value is int || entryU.value is double) {
            val = entryU.toString();
          } else {
            val = entryU.value;
          }
          debugPrint("<   ${entryU.key}>");
          debugPrint("        <$val>");
          debugPrint("    </${entryU.key}>");
        }
        debugPrint("<${entry.key}>");
        continue;
      }
      String val = "";
      if (entry.value == null) {
        val = "null";
      } else if (entry.value == "") {
        val = "empt";
      } else if (entry.value is int || entry.value is double) {
        val = entry.toString();
      } else {
        val = entry.value;
      }
      debugPrint("<${entry.key}>");
      debugPrint("    <$val>");
      debugPrint("</${entry.key}>");
      debugPrint(" ");
    }

    debugPrint("loginresponsedata: ${jsonEncode(json)}");

    return LoginResponse(
      id: json['id'] ?? "",
      message: json['message'] ?? "",
      token: json['token'] ?? "no-token",
      user: User.fromJson(userJson),
    );
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
