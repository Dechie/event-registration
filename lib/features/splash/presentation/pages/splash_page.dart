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
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.event,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // App Name
              const Text(
                'Event Registration',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'Connect. Learn. Grow.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
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
                      color: Colors.white.withOpacity(0.8),
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
