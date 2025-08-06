import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthHelper {
  static void checkAuthenticationAndNavigate(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(const CheckAuthStatusEvent());
  }

  static String? getCurrentUserByType(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      return authState.role;
    }
    return null;
  }

  static String? getCurrentUserEmail(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      return authState.email;
    }
    return null;
  }

  static String? getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      return authState.userId;
    }
    return null;
  }

  static bool isAdmin(BuildContext context) {
    final role = getCurrentUserByType(context);
    return role == "admin";
  }

  static bool isParticipant(BuildContext context) {
    final role = getCurrentUserByType(context);
    return role == "participant";
  }

  static bool isUserAuthenticated(BuildContext context) {
    final authState = context.read<AuthBloc>();
    return authState is AuthenticatedState;
  }

  static void logoutUser(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(const LogoutEvent());
  }

  static void showAuthError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showAuthSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
