part of 'splash_bloc.dart';
// splash_state.dart
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToRegistration extends SplashState {}

class SplashNavigateToEmailVerification extends SplashState {
  final String email;
  SplashNavigateToEmailVerification({required this.email});
}

class SplashNavigateToProfileCreation extends SplashState {
  final String email;
  SplashNavigateToProfileCreation({required this.email});
}

class SplashNavigateToLanding extends SplashState {}

class SplashNavigateToParticipantDashboard extends SplashState {
  final String email;
  SplashNavigateToParticipantDashboard({required this.email});
}

class SplashNavigateToAdminDashboard extends SplashState {}