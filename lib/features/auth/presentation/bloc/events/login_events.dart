part of 'auth_event.dart';

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String role; // 'participant' or 'admin'
  final bool rememberMe;

  const LoginEvent({
    required this.email,
    required this.password,
    required this.role,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, role, rememberMe];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
