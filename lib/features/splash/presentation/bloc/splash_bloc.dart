import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/auth_status.dart';
import '../../data/repositories/splash_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashRepository repository;

  SplashBloc({required this.repository}) : super(SplashInitial()) {
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
    on<InitializeApp>(_onInitializeApp);
  }

  Future<void> _onCheckAuthenticationStatus(
    CheckAuthenticationStatus event,
    Emitter<SplashState> emit,
  ) async {
    try {
      debugPrint("🔍 Checking authentication status...");
      final authStatus = await repository.checkAuthenticationStatus();

      debugPrint("📱 Auth Status: $authStatus");
      debugPrint(
        "🎯 Recommended destination: ${authStatus.recommendedDestination}",
      );

      // Use the recommended destination from AuthStatus
      switch (authStatus.recommendedDestination) {
        case NavDestination.registration:
          debugPrint("📍 → Registration Page");
          emit(SplashNavigateToRegistration());
          break;

        case NavDestination.emailVerification:
          debugPrint("📍 → Email Verification Page");
          emit(SplashNavigateToEmailVerification(email: authStatus.email!));
          break;

        case NavDestination.profileCreation:
          debugPrint("📍 → Profile Creation Page");
          emit(SplashNavigateToProfileCreation(email: authStatus.email!));
          break;

        case NavDestination.landing:
          debugPrint("splash bloc: determined navdestination: landingPage");
          debugPrint("📍 → Landing Page");
          emit(SplashNavigateToLanding());
          break;

        case NavDestination.participantDashboard:
          debugPrint("📍 → Participant Dashboard");
          emit(SplashNavigateToParticipantDashboard(email: authStatus.email!));
          break;

        case NavDestination.adminDashboard:
          debugPrint("📍 → Admin Dashboard");
          emit(SplashNavigateToAdminDashboard());
          break;

        case NavDestination.participantLogin:
          debugPrint("📍 → Participant Login");
          emit(SplashNavigateToParticipantLogin());
          break;

        case NavDestination.adminLogin:
          debugPrint("📍 → Admin Login");
          emit(SplashNavigateToAdminLogin());
          break;
      }
    } catch (e) {
      debugPrint("❌ Error during authentication check: $e");
      // If there's an error, navigate to landing page as fallback
      emit(SplashNavigateToRegistration());
    }
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());
    debugPrint("🚀 Initializing app...");

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check authentication status
    add(CheckAuthenticationStatus());
  }
}
