part of 'auth_event.dart';
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String userType; // 'participant' or 'admin'
  final bool rememberMe;

  const LoginEvent({
    required this.email,
    required this.password,
    required this.userType,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, userType, rememberMe];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}