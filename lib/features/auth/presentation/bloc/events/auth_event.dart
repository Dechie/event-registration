import 'package:equatable/equatable.dart';
part 'otp_events.dart';
part 'login_events.dart';
part 'profile_events.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

class RegisterUserEvent extends AuthEvent {
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;
  
  const RegisterUserEvent({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, passwordConfirmation, role];
}

class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordEvent({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}
