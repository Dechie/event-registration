import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

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

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthErrorState extends AuthState {
  final String message;
  final String? errorCode;

  const AuthErrorState({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
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

  @override
  List<Object?> get props => [message];
}
