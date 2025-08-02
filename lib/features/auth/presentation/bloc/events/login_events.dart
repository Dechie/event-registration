part of 'auth_event.dart';
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String userType; // 'participant' or 'admin'

  const LoginEvent({
    required this.email,
    required this.password,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, userType];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}