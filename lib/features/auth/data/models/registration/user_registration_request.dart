import 'package:equatable/equatable.dart';

class UserRegistrationRequest extends Equatable {
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role; // 'admin' or 'participant'

  const UserRegistrationRequest({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "role": role,
    };
  }

  @override
  List<Object?> get props => [email, password, passwordConfirmation, role];

  static UserRegistrationRequest fromJson(Map<String, dynamic> json) {
    return UserRegistrationRequest(
      email: json["email"],
      password: json["password"],
      passwordConfirmation: json["password-confirmation"],
      role: json["role"] ?? "participant",
    );
  }

  
}
