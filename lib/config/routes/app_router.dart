import 'package:flutter/material.dart';

import '../../features/registration/presentation/pages/registration_page.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        //return MaterialPageRoute(builder: (_) => const LandingPage());
        return MaterialPageRoute(builder: (_) => const Scaffold());
      case RouteNames.registrationPage:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case RouteNames.confirmationPage:
        // return MaterialPageRoute(
        //   builder: (_) => ConfirmationPage(
        //     registrationResult: settings.arguments as RegistrationSuccessState,
        //   ),
        // );
        return MaterialPageRoute(builder: (_) => const Scaffold());
      case RouteNames.loginPage:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Login Page - Coming Soon')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
