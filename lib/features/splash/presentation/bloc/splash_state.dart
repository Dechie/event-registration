part of 'splash_bloc.dart';

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToAdminDashboard extends SplashState {}

class SplashNavigateToLanding extends SplashState {}

class SplashNavigateToParticipantDashboard extends SplashState {
  final String email;
  SplashNavigateToParticipantDashboard({required this.email});
}

class SplashNavigateToSignUp extends SplashState {}

abstract class SplashState {}
