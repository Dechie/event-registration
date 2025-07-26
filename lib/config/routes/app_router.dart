import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/landing/lib/features/landing/presentation/pages/landing_page.dart';
import 'package:event_reg/features/splash/lib/features/splash/presentation/pages/splash_page.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/presentation/pages/participant_dashboard_page.dart';
import 'package:event_reg/features/registration/presentation/pages/registration_page.dart';
import 'package:flutter/material.dart';

import 'participant_login.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashPage:
        return MaterialPageRoute(builder: (_) => const SplashPage());
        
      case RouteNames.landingPage:
        return MaterialPageRoute(builder: (_) => const LandingPage());

      case RouteNames.registrationPage:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());

      case RouteNames.otpVerificationPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('OTP Verification')),
            body: const Center(child: Text('OTP Verification - To be implemented')),
          ),
        );

      case RouteNames.registrationSuccessPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Registration Success')),
            body: const Center(child: Text('Registration Success - To be implemented')),
          ),
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
        
      case RouteNames.adminLoginPage:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());

      case RouteNames.eventAgendaPage:
        return MaterialPageRoute(builder: (_) => const EventAgendaPage());
        
      case RouteNames.contactPage:
        return MaterialPageRoute(builder: (_) => const ContactPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: const Center(
        child: Text('Admin Login Page - To be implemented'),
      ),
    );
  }
}

class EventAgendaPage extends StatelessWidget {
  const EventAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Agenda')),
      body: const Center(
        child: Text('Event Agenda Page - To be implemented'),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: const Center(
        child: Text('Contact Us Page - To be implemented'),
      ),
    );
  }
}