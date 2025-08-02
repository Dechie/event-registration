import 'package:equatable/equatable.dart';
import 'package:event_reg/features/auth/data/models/user.dart';

class LoginResponse extends Equatable {
  final String token;
  final String? refreshToken;
  final User user;
  final DateTime expiresAt;

  const LoginResponse({
    required this.token,
    this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [token, refreshToken, user, expiresAt];
}