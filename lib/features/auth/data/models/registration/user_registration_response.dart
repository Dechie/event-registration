import 'package:equatable/equatable.dart';

class UserRegistrationResponse extends Equatable {
  final String message;
  final String userId;
  final String email;
  final String? otpToken;
  final bool otpSent;

  const UserRegistrationResponse({
    required this.message,
    required this.userId,
    required this.email,
    this.otpToken = '',
    required this.otpSent,
  });

  @override
  List<Object?> get props => [message, userId, email, otpToken, otpSent];
}
