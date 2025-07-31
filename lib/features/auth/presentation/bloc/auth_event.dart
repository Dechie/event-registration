import 'package:equatable/equatable.dart';

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

class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

class RegisterUserEvent extends AuthEvent {
  final String email;
  final String password;
  final String passwordConfirmation;
  const RegisterUserEvent({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [email, password, passwordConfirmation];
}

class ResendOTPEvent extends AuthEvent {
  final String email;

  const ResendOTPEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordEvent({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}

class VerifyOTPEvent extends AuthEvent {
  final String email;
  final String otp;
  final String? otpToken;

  const VerifyOTPEvent({
    required this.email,
    required this.otp,
    this.otpToken = '',
  });

  @override
  List<Object?> get props => [email, otp, otpToken];
}
