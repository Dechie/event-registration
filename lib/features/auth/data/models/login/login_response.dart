import 'package:event_reg/features/auth/data/models/user.dart';

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
    return LoginResponse(
      token: json["token"] ?? '',
      user: User.fromJson(json["user"] ?? {}),
      message: json["message"] ?? "Login Successful",
    );
  }

  Map<String, dynamic> toJson() {
    return {"token": token, "user": user.toJson, "message": message};
  }

  LoginResponse copyWith({String? token, User? user, String? message}) {
    return LoginResponse(
      token: token ?? this.token,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }
}
