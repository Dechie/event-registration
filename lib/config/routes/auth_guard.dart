// Auth Guard Widget to protect routes
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:event_reg/features/auth/presentation/pages/re_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String requiredrole;
  final String? debugName; // Add debug identifier

  const AuthGuard({
    super.key,
    required this.child,
    required this.requiredrole,
    this.debugName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final guardId = debugName ?? child.runtimeType.toString();
        debugPrint(
          "🛡️ AuthGuard[$guardId] - Required: $requiredrole, State: ${state.runtimeType}",
        );

        var stateRoleValue = "";

        if (state is AuthenticatedState) {
          stateRoleValue = state.role == "org_admin" ? "admin" : state.role;
          debugPrint(
            "🛡️ AuthGuard[$guardId] - User role: ${state.role} → Mapped: $stateRoleValue",
          );
        }

        if (state is AuthOTPVerifiedState) {
          stateRoleValue = state.role == "org_admin" ? "admin" : state.role;
          debugPrint(
            "🛡️ AuthGuard[$guardId] - OTP verified role: ${state.role} → Mapped: $stateRoleValue",
          );
        }

        // Loading state
        if (state is AuthLoadingState) {
          debugPrint(
            "🛡️ AuthGuard[$guardId] - Loading state, showing spinner",
          );

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthLoggedOutState) {
          debugPrint(
            "✅ AuthGuard[$guardId] - logged out state, push to relogin page",
          );

          return ReLoginPage();
        }
        // Check authentication and role match
        bool isAuthenticated =
            state is AuthenticatedState || state is AuthOTPVerifiedState;

        bool roleMatches = stateRoleValue == requiredrole;
        if (state is AuthenticatedState) {
          if ([state.role, stateRoleValue].contains("admin")) {
            roleMatches = true;
          }
        }

        if (isAuthenticated && roleMatches) {
          debugPrint("✅ AuthGuard[$guardId] - Access granted!");

          return child;
        }

        // Access denied - redirect to appropriate login
        if (isAuthenticated && !roleMatches) {
          debugPrint(
            "❌ AuthGuard[$guardId] - Role mismatch! Required: $requiredrole, Got: $stateRoleValue",
          );
        } else {
          debugPrint(
            "❌ AuthGuard[$guardId] - Not authenticated, redirecting to login",
          );
        }

        // Prevent multiple navigation calls
        // inside AuthGuard, replace the current WidgetsBinding.addPostFrameCallback(...) block
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          // Only redirect if this widget is the current route (prevents other guards from
          // stealing navigation while another route is being shown).
          final modal = ModalRoute.of(context);
          if (modal == null || modal.isCurrent != true) {
            debugPrint(
              "🔍 AuthGuard[$guardId] - not current route (modal: ${modal?.settings.name}), skipping redirect",
            );
            return;
          }

          final route = requiredrole == 'admin'
              ? RouteNames.adminLoginPage
              : RouteNames.participantLoginPage;

          debugPrint("🔄 AuthGuard[$guardId] - Redirecting to: $route");

          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
