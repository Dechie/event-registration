import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String email;
  final String password;
  final String userType;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.userType,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'user_type': userType,
      'remember_me': rememberMe,
    };
  }

  @override
  List<Object?> get props => [email, password, userType, rememberMe];
}
