import 'package:equatable/equatable.dart';

class UserRegistrationRequest extends Equatable {
  final String email;
  final String password;
  final String passwordConfirmation;

  const UserRegistrationRequest({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };
  }

  @override
  List<Object?> get props => [email, password, passwordConfirmation];

  static UserRegistrationRequest fromJson(Map<String, dynamic> json) {
    return UserRegistrationRequest(
      email: json["email"],
      password: json["password"],
      passwordConfirmation: json["password-confirmation"],
    );
  }
}
