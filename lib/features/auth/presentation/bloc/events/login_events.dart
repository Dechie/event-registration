part of 'auth_event.dart';

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String role; // 'participant' or 'admin'

  const LoginEvent({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
