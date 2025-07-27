import 'package:event_reg/features/splash/data/models/auth_status.dart';

class LoginResponse {
  final String token;
  final String email;
  final String name;
  final UserType userType; // Changed to UserType enum
  final String userId;

  const LoginResponse({
    required this.token,
    required this.email,
    required this.name,
    required this.userType,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['userType'],
        orElse: () => UserType.none, // Fallback for safety
      ),
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'name': name,
      'userType': userType.toString().split('.').last,
      'userId': userId,
    };
  }

  // Helper methods
  bool get isParticipant => userType == UserType.participant;
  bool get isAdmin => userType == UserType.admin;
}
