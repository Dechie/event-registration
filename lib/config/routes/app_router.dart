import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:event_reg/features/attendance/presentation/pages/event_details_page.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:event_reg/features/auth/presentation/pages/auth_otp_verification_page.dart';
import 'package:event_reg/features/auth/presentation/pages/login/admin_login.dart';
import 'package:event_reg/features/auth/presentation/pages/login/participant_login.dart';
import 'package:event_reg/features/auth/presentation/pages/profile_add_page.dart';
import 'package:event_reg/features/auth/presentation/pages/user_registration.dart';
import 'package:event_reg/features/badge/presentation/pages/badge_page.dart';
import 'package:event_reg/features/landing/presentation/pages/landing_page.dart';
import 'package:event_reg/features/splash/presentation/pages/splash_page.dart';
import 'package:event_reg/features/verification/presentation/pages/coupon_selection_page.dart';
import 'package:event_reg/features/verification/presentation/pages/qr_scanner/qr_scanner_page.dart';
import 'package:event_reg/features/verification/presentation/pages/verification_result_page.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/attendance/presentation/pages/event_list_page.dart';
import '../../features/attendance/presentation/pages/room_list_page.dart';

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
          builder: (_) => const UserRegistrationPage(),
          settings: settings,
        );

      case RouteNames.otpVerificationPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthOTPVerificationPage(
            email: args?['email'] ?? '',
            otpToken: args?['otpToken'],
            message: args?['message'],
            role: args?['role'],
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

      case RouteNames.adminDashboardPage:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      case RouteNames.qrScannerPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QrScannerPage(
            verificationType: args?['type'] ?? 'security',
            eventId: args?['eventId'],
            eventSessionId: args?['eventSessionId'],
            sessionTitle: args?['sessionTitle'],
            roomId: args?['roomId'],
          ),
        );

      case RouteNames.couponSelectionPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args['bloc'],
            child: CouponSelectionPage(
              coupons: args['coupons'],
              participant: args['participant'],
              badgeNumber: args['badgeNumber'],
            ),
          ),
        );

      case RouteNames.verificationResultPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VerificationResultPage(
            verificationType: args['type'],
            response: args['response'],
            badgeNumber: args['badgeNumber'],
          ),
        );
      case RouteNames.eventListPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<AttendanceBloc>(),
            child: const EventListPage(),
          ),
        );

      case RouteNames.eventDetailsPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args['bloc'],
            child: EventDetailsPage(
              event: args['event'],
            ), // Note: renamed to avoid conflict
          ),
        );

      case RouteNames.roomListPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args['bloc'],
            child: RoomListPage(event: args['event'], session: args['session']),
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
  final String requiredrole;

  const AuthGuard({super.key, required this.child, required this.requiredrole});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        debugPrint("required role: $requiredrole");
        if (state is AuthenticatedState) {
          debugPrint("state role: ${state.role}");
        }
        if (state is AuthOTPVerifiedState) {
          debugPrint("state role: ${state.role}");
        }

        if (state is AuthLoadingState) {
          debugPrint(
            "at authguard: state is: ${state.runtimeType}, should be loading now",
          );

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthenticatedState && state.role == requiredrole) {
          debugPrint(
            "at authguard: state is: ${state.runtimeType}, role is: ${state.role}, should return proper next page",
          );

          return child;
        }

        if (state is AuthOTPVerifiedState && state.role == requiredrole) {
          debugPrint(
            "at authguard: state is: ${state.runtimeType}, role is: ${state.role}, should return proper next page",
          );

          return child;
        }

        // If none of the above conditions are met, redirect to the login page.
        debugPrint(
          "at authguard: state is: ${state.runtimeType}, force push to next page",
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final route = requiredrole == 'admin'
              ? RouteNames.adminLoginPage
              : RouteNames.participantLoginPage;
          Navigator.pushReplacementNamed(context, route);
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
