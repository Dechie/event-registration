// Auth Guard Widget to protect routes
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
