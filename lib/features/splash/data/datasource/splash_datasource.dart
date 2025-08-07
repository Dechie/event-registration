import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/splash/data/models/auth_status.dart';
import 'package:flutter/material.dart';

abstract class SplashLocalDataSource {
  Future<void> clearAuthData();
  Future<AuthStatus> getAuthStatus();
  Future<void> saveAuthStatus(AuthStatus authStatus);
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final UserDataService userDataService;

  SplashLocalDataSourceImpl({required this.userDataService});

  @override
  Future<void> clearAuthData() async {
    debugPrint("🧹 Clearing auth data from splash datasource");
    await userDataService.clearAllData();
  }

  @override
  Future<AuthStatus> getAuthStatus() async {
    debugPrint("🔍 Getting auth status from splash datasource");

    try {
      final authStatus = await userDataService.getAuthenticationStatus();
      debugPrint("📱 Authentication status retrieved: $authStatus");

      if (!authStatus.isAuthenticated) {
        debugPrint("❌ User not authenticated");
        return AuthStatus(role: Role.none);
      }

      // Determine user type
      Role role = Role.none;
      if (authStatus.role != null) {
        switch (authStatus.role!.toLowerCase()) {
          case 'participant':
            role = Role.participant;
            break;
          case 'admin':
            role = Role.admin;
            break;
          default:
            role = Role.none;
        }
      }

      // ADD THIS LOGIC: If user has a token, assume email is verified
      bool emailVerified = authStatus.isEmailVerified;
      if (authStatus.token != null && authStatus.token!.isNotEmpty) {
        emailVerified =
            true; // Assume email is verified if user has valid token
      }

      return AuthStatus(
        role: role,
        token: authStatus.token,
        email: authStatus.email,
        userId: authStatus.userId,
        isEmailVerified: emailVerified, // Use the updated status
        hasProfile: authStatus.hasProfile,
      );
    } catch (e) {
      debugPrint("❌ Error getting auth status: $e");
      return AuthStatus(role: Role.none);
    }
  }

  @override
  Future<void> saveAuthStatus(AuthStatus authStatus) async {
    debugPrint("💾 Saving auth status from splash datasource");

    try {
      if (authStatus.token != null) {
        await userDataService.setAuthToken(authStatus.token!);
      }

      if (authStatus.role != Role.none) {
        await userDataService.setRole(
          authStatus.role.toString().split('.').last,
        );
      }

      if (authStatus.email != null) {
        await userDataService.setUserEmail(authStatus.email!);
      }

      if (authStatus.userId != null) {
        await userDataService.setUserEmail(authStatus.userId!);
      }

      // Save additional status flags
      await userDataService.setEmailVerified(authStatus.isEmailVerified);
      await userDataService.setHasProfile(authStatus.hasProfile);
      await userDataService.setProfileCompleted(authStatus.hasProfile);

      debugPrint("✅ Auth status saved successfully");
    } catch (e) {
      debugPrint("❌ Failed to save auth status: $e");
    }
  }
}
