// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:event_reg/features/auth/data/models/user.dart';

class AuthenticatedState extends AuthState {
  final String userId;
  final String email;
  final String role; // 'participant' or 'admin'
  final String? token;
  final Map<String, dynamic>? userData;

  const AuthenticatedState({
    required this.userId,
    required this.email,
    required this.role,
    this.token,
    this.userData,
  });

  @override
  List<Object?> get props => [userId, email, role, token, userData];
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

class AuthLoggedOutState extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthOTPSentState extends AuthState {
  final String message;
  final String email;

  const AuthOTPSentState({required this.message, required this.email});

  @override
  List<Object?> get props => [message, email];
}

class AuthOTPVerifiedState extends AuthState {
  final String message;
  final String email;
  final String role;

  const AuthOTPVerifiedState({
    required this.message,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [message, email, role];
}

class AuthProfileCreatedState extends AuthState {
  final String message;
  final User userData;
  const AuthProfileCreatedState({
    required this.message,
    required this.userData,
  });
}

class AuthProfileUpdatedState extends AuthState {
  final String message;
  final Map<String, dynamic> userData;

  const AuthProfileUpdatedState({
    required this.message,
    required this.userData,
  });
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
