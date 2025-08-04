// lib/config/routes/app_router.dart
import 'package:event_reg/config/routes/route_names.dart';
// Import BLoCs
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:event_reg/features/auth/presentation/pages/auth_otp_verification_page.dart';
import 'package:event_reg/features/auth/presentation/pages/login/admin_login_page.dart'; // New admin login
import 'package:event_reg/features/auth/presentation/pages/login/participant_login.dart';
import 'package:event_reg/features/auth/presentation/pages/profile_add_page.dart';
import 'package:event_reg/features/auth/presentation/pages/user_registration.dart';
import 'package:event_reg/features/badge/presentation/pages/badge_page.dart';
import 'package:event_reg/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:event_reg/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:event_reg/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:event_reg/features/dashboard/presentation/pages/participant_dashboard_page.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_bloc.dart';
import 'package:event_reg/features/event_registration/presentation/pages/my_events_page.dart';
import 'package:event_reg/features/landing/presentation/pages/landing_page.dart';
import 'package:event_reg/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:event_reg/features/registration/presentation/pages/registration_page.dart';
import 'package:event_reg/features/splash/presentation/pages/splash_page.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                di.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
            child: const SplashPage(),
          ),
        );

      case RouteNames.landingPage:
        return MaterialPageRoute(builder: (_) => const UpdatedLandingPage());

      case RouteNames.myEventsPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<EventRegistrationBloc>(),
            child: MyEventsPage(),
          ),
        );

      case RouteNames.badgePage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BadgePage(
            event: args["event"],
            registrationData: args["registrationData"],
          ),
        );

      case RouteNames.registrationPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<RegistrationBloc>(),
            child: const RegistrationPage(),
          ),
        );

      case RouteNames.userRegistrationPage:
        return MaterialPageRoute(
          builder: (_) => const UserRegistrationPage(),
          settings: settings,
        );

      case RouteNames.authOtpVerificationPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthOTPVerificationPage(
            email: args?['email'] ?? '',
            otpToken: args?['otpToken'],
            message: args?['message'],
          ),
          settings: settings,
        );

      case RouteNames.profileAddPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<AuthBloc>(),
            child: ProfileAddPage(
              isEditMode: args["isEditMode"] ?? false,
              existingProfileData: {},
            ),
          ),
        );

      case RouteNames.participantLoginPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<AuthBloc>(),
            child: const ParticipantLoginPage(),
          ),
        );

      case RouteNames.adminLoginPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<AuthBloc>(),
            child: const AdminLoginPage(),
          ),
        );

      case RouteNames.participantDashboardPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            requiredUserType: 'participant',
            child: BlocProvider(
              create: (context) => di.sl<DashboardBloc>()
                ..add(
                  LoadParticipantDashboardEvent(
                        email: args?['email'] as String? ?? '',
                      )
                      as DashboardEvent,
                ),
              child: ParticipantDashboardPage(email: args?['email'] ?? ''),
            ),
          ),
        );

      case RouteNames.adminDashboardPage:
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            requiredUserType: 'admin',
            child: BlocProvider(
              create: (context) =>
                  di.sl<DashboardBloc>()
                    ..add(const LoadAdminDashboardEvent() as DashboardEvent),
              child: const AdminDashboardPage(),
            ),
          ),
        );

      case RouteNames.eventAgendaPage:
        return MaterialPageRoute(builder: (_) => const EventAgendaPage());

      case RouteNames.contactPage:
        return MaterialPageRoute(builder: (_) => const ContactPage());

      case RouteNames.faqPage:
        return MaterialPageRoute(builder: (_) => const FAQPage());

      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundPage(routeName: settings.name),
        );
    }
  }
}

// Auth Guard Widget to protect routes
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String requiredUserType; // 'admin' or 'participant'

  const AuthGuard({
    super.key,
    required this.child,
    required this.requiredUserType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthenticatedState && state.userType == requiredUserType) {
          return child;
        } else if (state is AuthLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // Redirect to appropriate login page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final route = requiredUserType == 'admin'
                ? RouteNames.adminLoginPage
                : RouteNames.participantLoginPage;
            Navigator.pushReplacementNamed(context, route);
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us'), centerTitle: true),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contact_support, size: 80, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Contact Us',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Contact Us Page - To be implemented',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventAgendaPage extends StatelessWidget {
  const EventAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Agenda'), centerTitle: true),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Event Agenda',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Event Agenda Page - To be implemented',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ'), centerTitle: true),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 80, color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text('FAQ Page - To be implemented', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadAdminDashboardEvent {
  const LoadAdminDashboardEvent();
}

// Add these placeholder events to your dashboard bloc
class LoadParticipantDashboardEvent {
  final String email;
  const LoadParticipantDashboardEvent({required this.email});
}

// Enhanced Not Found Page
class NotFoundPage extends StatelessWidget {
  final String? routeName;

  const NotFoundPage({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, RouteNames.landingPage),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 100, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                '404',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              if (routeName != null)
                Text(
                  'No route defined for "$routeName"',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  RouteNames.landingPage,
                ),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
