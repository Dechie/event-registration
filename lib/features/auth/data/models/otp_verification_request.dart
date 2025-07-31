import 'package:equatable/equatable.dart';

class OtpVerificationRequest extends Equatable {
  final String email;
  final String otp;
  final String? otpToken;

  const OtpVerificationRequest({
    required this.email,
    required this.otp,
    this.otpToken = '',
  });

  @override
  List<Object?> get props => [email, otp, otpToken];

  OtpVerificationRequest copyWith({
    String? email,
    String? otp,
    String? otpToken,
  }) {
    return OtpVerificationRequest(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      otpToken: otpToken ?? this.otpToken,
    );
  }
}
