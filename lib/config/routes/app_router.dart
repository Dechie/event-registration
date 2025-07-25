import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/presentation/pages/participant_dashboard_page.dart';
import 'package:event_reg/features/registration/presentation/pages/registration_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.registrationPage:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());

      case RouteNames.otpVerificationPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          // builder: (_) => OtpVerificationPage(
          //   email: args?['email'] ?? '',
          // ),
          builder: (_) => Scaffold(),
        );

      case RouteNames.registrationSuccessPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          // builder: (_) => RegistrationSuccessPage(
          //   participant: args?['participant'],
          //   qrCode: args?['qrCode'] ?? '',
          // ),
          builder: (_) => Scaffold(),
        );

      case RouteNames.adminDashboardPage:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      case RouteNames.participantDashboardPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ParticipantDashboardPage(email: args?['email'] ?? ''),
        );

      case RouteNames.participantLoginPage:
        return MaterialPageRoute(builder: (_) => const ParticipantLoginPage());

      case RouteNames.landingPage:
        return MaterialPageRoute(builder: (_) => const LandingPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Registration')),
      body: const Center(child: Text('Landing Page - To be implemented')),
    );
  }
}

// Placeholder pages for missing routes
class ParticipantLoginPage extends StatelessWidget {
  const ParticipantLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participant Login')),
      body: const Center(
        child: Text('Participant Login Page - To be implemented'),
      ),
    );
  }
}
