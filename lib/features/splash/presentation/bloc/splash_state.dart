part of 'splash_bloc.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToLanding extends SplashState {}

class SplashNavigateToParticipantDashboard extends SplashState {
  final String email;
  SplashNavigateToParticipantDashboard({required this.email});
}

class SplashNavigateToAdminDashboard extends SplashState {}
