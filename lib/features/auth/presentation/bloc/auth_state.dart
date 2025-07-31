// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';

class AuthenticatedState extends AuthState {
  final String userId;
  final String email;
  final String userType; // 'participant' or 'admin'
  final String? token;
  final Map<String, dynamic>? userData;

  const AuthenticatedState({
    required this.userId,
    required this.email,
    required this.userType,
    this.token,
    this.userData,
  });

  @override
  List<Object?> get props => [userId, email, userType, token, userData];
}

class AuthErrorState extends AuthState {
  final String message;
  final String? errorCode;

  const AuthErrorState({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordSuccessState extends AuthState {
  final String message;

  const ForgotPasswordSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

class PasswordResetSuccessState extends AuthState {
  final String message;

  const PasswordResetSuccessState({required this.message});
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthRegistrationSuccessState extends AuthState {
  final String message;
  final String userId;
  final String email;
  final bool otpSent;
  final String? otpToken;

  const AuthRegistrationSuccessState({
    required this.message,
    required this.userId,
    required this.email,
    required this.otpSent,
    required this.otpToken,
  });

  @override
  List<Object?> get props => [message, userId, email, otpSent, otpToken];
}

class AuthOTPVerifiedState extends AuthState {
  final String message;
  final String email;

  const AuthOTPVerifiedState({required this.message, required this.email});

  @override
  List<Object?> get props => [message, email];
}

class AuthOTPSentState extends AuthState {
  final String message;
  final String email;

  const AuthOTPSentState({required this.message, required this.email});

  @override
  List<Object?> get props => [message, email];
}
