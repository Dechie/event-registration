// import 'package:event_reg/config/routes/auth_guard.dart';
// import 'package:event_reg/config/routes/route_names.dart';
// import 'package:event_reg/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
// import 'package:event_reg/features/attendance/presentation/pages/event_details_page.dart';
// import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_bloc.dart';
// import 'package:event_reg/features/attendance_report/presentation/pages/attendance_report_page.dart';
// import 'package:event_reg/features/auth/presentation/pages/auth_otp_verification_page.dart';
// import 'package:event_reg/features/auth/presentation/pages/login/admin_login.dart';
// import 'package:event_reg/features/auth/presentation/pages/login/participant_login.dart';
// import 'package:event_reg/features/auth/presentation/pages/profile_add_page.dart';
// import 'package:event_reg/features/auth/presentation/pages/re_login_page.dart';
// import 'package:event_reg/features/auth/presentation/pages/user_registration.dart';
// import 'package:event_reg/features/badge/presentation/pages/badge_page.dart';
// import 'package:event_reg/features/landing/presentation/pages/landing_page.dart';
// import 'package:event_reg/features/reports/presentation/bloc/reports_bloc.dart';
// import 'package:event_reg/features/reports/presentation/pages/session_report_page.dart';
// import 'package:event_reg/features/splash/presentation/bloc/splash_bloc.dart';
// import 'package:event_reg/features/splash/presentation/pages/splash_page.dart';
// import 'package:event_reg/features/verification/presentation/bloc/verification_bloc.dart';
// import 'package:event_reg/features/verification/presentation/pages/coupon_selection_page.dart';
// import 'package:event_reg/features/verification/presentation/pages/qr_scanner/qr_scanner_page.dart';
// import 'package:event_reg/features/verification/presentation/pages/verification_result_page.dart';
// import 'package:event_reg/injection_container.dart' as di;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../features/attendance/presentation/pages/event_list_page.dart';
// import '../../features/reports/presentation/pages/event_report_page.dart';

// class AppRouter {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case RouteNames.splashPage:
//         return MaterialPageRoute(
//           builder: (_) => BlocProvider<SplashBloc>(
//             create: (context) =>
//                 di.sl<SplashBloc>()
//                   ..add(InitializeApp()), // Or add(CheckAuthenticationStatus())
//             child: const SplashPage(),
//           ),
//         );

//       case RouteNames.landingPage:
//         debugPrint("redirected to landing page");
//         return MaterialPageRoute(
//           builder: (_) => AuthGuard(
//             requiredrole: 'participant',
//             child: const UpdatedLandingPage(),
//           ),
//         );
//       case RouteNames.badgePage:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => BadgePage(
//             event: args["event"],
//             registrationData: args["registrationData"],
//           ),
//         );

//       case RouteNames.registrationPage:
//         return MaterialPageRoute(
//           builder: (_) => const UserRegistrationPage(),
//           settings: settings,
//         );

//       case RouteNames.otpVerificationPage:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => AuthOTPVerificationPage(
//             email: args?['email'] ?? '',
//             otpToken: args?['otpToken'],
//             message: args?['message'],
//             role: args?['role'],
//           ),
//           settings: settings,
//         );

//       case RouteNames.profileAddPage:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => ProfileAddPage(
//             isEditMode: args["isEditMode"] ?? false,
//             existingProfileData: {},
//           ),
//         );

//       case RouteNames.participantLoginPage:
//         return MaterialPageRoute(builder: (_) => const ParticipantLoginPage());

//       case RouteNames.adminLoginPage:
//         return MaterialPageRoute(builder: (_) => const AdminLoginPage());
//       case RouteNames.reloginPage:
//         return MaterialPageRoute(builder: (_) => ReLoginPage());

//       case RouteNames.adminDashboardPage:
//         debugPrint("redirected to admin dashboard page");
//         return MaterialPageRoute(
//           builder: (_) => AuthGuard(
//             requiredrole: 'admin',
//             child: const AdminDashboardPage(),
//           ),
//         );
//       case RouteNames.qrScannerPage:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => QrScannerPage(
//             verificationType: args?['type'] ?? 'security',
//             eventId: args?['eventId'],
//             eventSessionId: args?['eventSessionId'],
//             sessionTitle: args?['sessionTitle'],
//             sessionLocationId: args?['sessionLocationId'],
//             roomId: args?['roomId'],
//           ),
//         );

//       case RouteNames.couponSelectionPage:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => BlocProvider.value(
//             value: args['bloc'],
//             child: CouponSelectionPage(
//               coupons: args['coupons'],
//               participant: args['participant'],
//               badgeNumber: args['badgeNumber'],
//             ),
//           ),
//         );

//       case RouteNames.verificationResultPage:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => VerificationResultPage(
//             verificationType: args['type'],
//             response: args['response'],
//             badgeNumber: args['badgeNumber'],
//           ),
//         );
//       case RouteNames.eventListPage:
//         return MaterialPageRoute(
//           builder: (_) => BlocProvider(
//             create: (context) => di.sl<VerificationBloc>(),
//             child: const EventListPage(),
//           ),
//         );

//       case RouteNames.eventDetailsPage:
//         final args = settings.arguments as Map<String, dynamic>;
//         debugPrint("args passed to event details page:");
//         debugPrint(args.toString());
//         return MaterialPageRoute(
//           builder: (_) => BlocProvider.value(
//             value: args['bloc'],
//             child: EventDetailsPage(
//               event: args['event'],
//             ), // Note: renamed to avoid conflict
//           ),
//         );

//       case RouteNames.eventAgendaPage:
//         return MaterialPageRoute(builder: (_) => const EventAgendaPage());

//       case RouteNames.attendanceReportPage:
//         return MaterialPageRoute(
//           builder: (_) => BlocProvider(
//             create: (context) => di.sl<AttendanceReportBloc>(),
//             child: const AttendanceReportPage(),
//           ),
//         );

//       case RouteNames.eventReportPage:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => BlocProvider(
//             create: (context) => di.sl<ReportBloc>(),
//             child: EventReportPage(
//               eventId:
//                   int.tryParse(args['eventId']) ??
//                   1, // this could cause issues down the line since you gave it a commonly occurring id number as a fallback.
//               eventTitle: args['eventTitle'],
//             ),
//           ),
//         );

//       case RouteNames.sessionReportPage:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => BlocProvider(
//             create: (context) => di.sl<ReportBloc>(),
//             child: SessionReportPage(
//               sessionId: int.tryParse(args['sessionId']) ?? 1,
//               sessionTitle: args['sessionTitle'],
//             ),
//           ),
//         );

//       case RouteNames.contactPage:
//         return MaterialPageRoute(builder: (_) => const ContactPage());

//       case RouteNames.faqPage:
//         return MaterialPageRoute(builder: (_) => const FAQPage());

//       default:
//         return MaterialPageRoute(
//           builder: (_) => NotFoundPage(routeName: settings.name),
//         );
//     }
//   }
// }

// class ContactPage extends StatelessWidget {
//   const ContactPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Contact Us'), centerTitle: true),
//       body: const Center(
//         child: Padding(
//           padding: EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.contact_support, size: 80, color: Colors.green),
//               SizedBox(height: 16),
//               Text(
//                 'Contact Us',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Contact Us Page - To be implemented',
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class EventAgendaPage extends StatelessWidget {
//   const EventAgendaPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Event Agenda'), centerTitle: true),
//       body: const Center(
//         child: Padding(
//           padding: EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.event_note, size: 80, color: Colors.blue),
//               SizedBox(height: 16),
//               Text(
//                 'Event Agenda',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Event Agenda Page - To be implemented',
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class FAQPage extends StatelessWidget {
//   const FAQPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('FAQ'), centerTitle: true),
//       body: const Center(
//         child: Padding(
//           padding: EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.help_outline, size: 80, color: Colors.purple),
//               SizedBox(height: 16),
//               Text(
//                 'Frequently Asked Questions',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               Text('FAQ Page - To be implemented', textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LoadAdminDashboardEvent {
//   const LoadAdminDashboardEvent();
// }

// // Add these placeholder events to your dashboard bloc
// class LoadParticipantDashboardEvent {
//   final String email;
//   const LoadParticipantDashboardEvent({required this.email});
// }

// // Enhanced Not Found Page
// class NotFoundPage extends StatelessWidget {
//   final String? routeName;

//   const NotFoundPage({super.key, this.routeName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Page Not Found'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () =>
//               Navigator.pushReplacementNamed(context, RouteNames.landingPage),
//         ),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 100, color: Colors.grey[400]),
//               const SizedBox(height: 24),
//               Text(
//                 '404',
//                 style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Page Not Found',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
//               ),
//               const SizedBox(height: 16),
//               if (routeName != null)
//                 Text(
//                   'No route defined for "$routeName"',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
//                 ),
//               const SizedBox(height: 32),
//               ElevatedButton.icon(
//                 onPressed: () => Navigator.pushReplacementNamed(
//                   context,
//                   RouteNames.landingPage,
//                 ),
//                 icon: const Icon(Icons.home),
//                 label: const Text('Go to Home'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(200, 48),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:event_reg/config/routes/auth_guard.dart';
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/admin_dashboard/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:event_reg/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:event_reg/features/attendance/presentation/pages/event_details_page.dart';
import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_bloc.dart';
import 'package:event_reg/features/attendance_report/presentation/pages/attendance_report_page.dart';
import 'package:event_reg/features/auth/presentation/pages/auth_otp_verification_page.dart';
import 'package:event_reg/features/auth/presentation/pages/login/admin_login.dart';
import 'package:event_reg/features/auth/presentation/pages/login/participant_login.dart';
import 'package:event_reg/features/auth/presentation/pages/profile_add_page.dart';
import 'package:event_reg/features/auth/presentation/pages/re_login_page.dart';
import 'package:event_reg/features/auth/presentation/pages/user_registration.dart';
import 'package:event_reg/features/badge/presentation/pages/badge_page.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_bloc.dart';
import 'package:event_reg/features/landing/presentation/pages/landing_page.dart';
import 'package:event_reg/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:event_reg/features/reports/presentation/pages/session_report_page.dart';
import 'package:event_reg/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:event_reg/features/splash/presentation/pages/splash_page.dart';
import 'package:event_reg/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:event_reg/features/verification/presentation/pages/coupon_selection_page.dart';
import 'package:event_reg/features/verification/presentation/pages/qr_scanner/qr_scanner_page.dart';
import 'package:event_reg/features/verification/presentation/pages/verification_result_page.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/attendance/presentation/pages/event_list_page.dart';
import '../../features/reports/presentation/pages/event_report_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint("🚨 Generating route: ${settings.name}");

    switch (settings.name) {
      case RouteNames.splashPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<SplashBloc>(
            create: (context) => di.sl<SplashBloc>()..add(InitializeApp()),
            child: const SplashPage(),
          ),
        );

      case RouteNames.landingPage:
        debugPrint("🏠 Routing to landing page with participant guard");
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<EventRegistrationBloc>()),
              // Add other BLoCs needed for landing page
            ],
            child: AuthGuard(
              requiredrole: 'participant',
              debugName: 'LandingPage',
              child: const UpdatedLandingPage(),
            ),
          ),
        );

      case RouteNames.adminDashboardPage:
        debugPrint("👨‍💼 Routing to admin dashboard with admin guard");
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<AdminDashboardBloc>(),
            child: AuthGuard(
              requiredrole: 'admin',
              debugName: 'AdminDashboard',
              child: const AdminDashboardPage(),
            ),
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
          builder: (_) => ProfileAddPage(
            isEditMode: args["isEditMode"] ?? false,
            existingProfileData: {},
          ),
        );

      case RouteNames.participantLoginPage:
        return MaterialPageRoute(builder: (_) => const ParticipantLoginPage());

      case RouteNames.adminLoginPage:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());

      case RouteNames.reloginPage:
        return MaterialPageRoute(builder: (_) => ReLoginPage());

      case RouteNames.qrScannerPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QrScannerPage(
            verificationType: args?['type'] ?? 'security',
            eventId: args?['eventId'],
            eventSessionId: args?['eventSessionId'],
            sessionTitle: args?['sessionTitle'],
            sessionLocationId: args?['sessionLocationId'],
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
            create: (context) => di.sl<VerificationBloc>(),
            child: const EventListPage(),
          ),
        );

      case RouteNames.eventDetailsPage:
        final args = settings.arguments as Map<String, dynamic>;
        debugPrint("📅 Event details args: $args");
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args['bloc'],
            child: EventDetailsPage(event: args['event']),
          ),
        );

      case RouteNames.eventAgendaPage:
        return MaterialPageRoute(builder: (_) => const EventAgendaPage());

      case RouteNames.attendanceReportPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<AttendanceReportBloc>(),
            child: const AttendanceReportPage(),
          ),
        );

      case RouteNames.eventReportPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<ReportBloc>(),
            child: EventReportPage(
              eventId: int.tryParse(args['eventId']) ?? 1,
              eventTitle: args['eventTitle'],
            ),
          ),
        );

      case RouteNames.sessionReportPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<ReportBloc>(),
            child: SessionReportPage(
              sessionId: int.tryParse(args['sessionId']) ?? 1,
              sessionTitle: args['sessionTitle'],
            ),
          ),
        );

      case RouteNames.contactPage:
        return MaterialPageRoute(builder: (_) => const ContactPage());

      case RouteNames.faqPage:
        return MaterialPageRoute(builder: (_) => const FAQPage());

      default:
        debugPrint("❓ Unknown route: ${settings.name}");
        return MaterialPageRoute(
          builder: (_) => NotFoundPage(routeName: settings.name),
        );
    }
  }
}

// Keep your existing placeholder pages...
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

class LoadParticipantDashboardEvent {
  final String email;
  const LoadParticipantDashboardEvent({required this.email});
}

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
