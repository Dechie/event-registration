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
    await userDataService.clearAllData();
  }

  @override
  Future<AuthStatus> getAuthStatus() async {
    debugPrint("splash local datasource: came here to see this");
    final token = await userDataService.getAuthToken();
    final userTypeString = await userDataService.getUserType();
    final email = await userDataService.getUserEmail() ?? "no email";
    debugPrint("token: $token, user type: $userTypeString, email: $email");

    if (token == null || userTypeString == null) {
      return AuthStatus(userType: UserType.none);
    }

    final userType = UserType.values.firstWhere(
      (type) => type.toString() == userTypeString,
      orElse: () => UserType.none,
    );

    return AuthStatus(userType: userType, token: token, email: email);
  }

  @override
  Future<void> saveAuthStatus(AuthStatus authStatus) async {
    if (authStatus.token != null) {
      await userDataService.setAuthToken(authStatus.token!);
    }
    await userDataService.setUserType(authStatus.userType.toString());
    if (authStatus.email != null) {
      await userDataService.setUserEmail(authStatus.email!);
    }
  }
}
