import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        debugPrint("🎯 Splash navigation state: ${state.runtimeType}");

        if (state is SplashNavigateToLanding) {
          debugPrint("📍 Navigating to Landing Page");
          Navigator.pushReplacementNamed(context, RouteNames.landingPage);
        } else if (state is SplashNavigateToParticipantDashboard) {
          debugPrint("📍 Navigating to Participant Dashboard: ${state.email}");
          Navigator.pushReplacementNamed(
            context,
            RouteNames.landingPage,
            //arguments: {'email': state.email},
          );
        } else if (state is SplashNavigateToAdminDashboard) {
          debugPrint("📍 Navigating to Admin Dashboard");
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.adminDashboardPage,
            (route) => false,
          );
        } else if (state is SplashNavigateToRegistration) {
          debugPrint("📍 Navigating to Registration Page");
          Navigator.pushReplacementNamed(context, RouteNames.registrationPage);
        } else if (state is SplashNavigateToEmailVerification) {
          debugPrint("📍 Navigating to Email Verification: ${state.email}");
          Navigator.pushReplacementNamed(
            context,
            RouteNames.otpVerificationPage,
            arguments: {'email': state.email},
          );
        } else if (state is SplashNavigateToProfileCreation) {
          debugPrint("📍 Navigating to Profile Creation: ${state.email}");
          Navigator.pushReplacementNamed(
            context,
            RouteNames.profileAddPage,
            arguments: {'email': state.email},
          );
        } else if (state is SplashNavigateToAdminLogin) {
          debugPrint("📍 Navigating to Admin Login");
          Navigator.pushReplacementNamed(context, RouteNames.adminLoginPage);
        } else if (state is SplashNavigateToParticipantLogin) {
          debugPrint("📍 Navigating to Participant Login");
          Navigator.pushReplacementNamed(
            context,
            RouteNames.participantLoginPage,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset("assets/logo.png"),
              ),
              const SizedBox(height: 24),

              // App Name
              const Text(
                'EventHub',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'Connect. Learn. Grow.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              // Loading Indicator
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),

              // Loading text
              BlocBuilder<SplashBloc, SplashState>(
                builder: (context, state) {
                  String loadingText = "Initializing...";
                  if (state is SplashLoading) {
                    loadingText = "Loading...";
                  }

                  return Text(
                    loadingText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
