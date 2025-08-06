part of 'auth_event.dart';

class ResendOTPEvent extends AuthEvent {
  final String email;

  const ResendOTPEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyOTPEvent extends AuthEvent {
  final String email;
  final String otp;
  final String? otpToken;
  final String role;

  const VerifyOTPEvent({
    required this.email,
    required this.otp,
    this.otpToken = '',
    required this.role,
  });

  @override
  List<Object?> get props => [email, otp, otpToken, role];
}
