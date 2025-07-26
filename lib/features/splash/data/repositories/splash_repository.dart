import 'package:event_reg/features/splash/data/datasource/splash_datasource.dart';
import 'package:flutter/material.dart';

import '../models/auth_status.dart';

abstract class SplashRepository {
  Future<AuthStatus> checkAuthenticationStatus();
  Future<void> clearAuthenticationData();
}

class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource localDataSource;

  SplashRepositoryImpl({required this.localDataSource});

  @override
  Future<AuthStatus> checkAuthenticationStatus() async {
    try {
      debugPrint("splash repo: came here");
      return await localDataSource.getAuthStatus();
    } catch (e) {
      return AuthStatus(userType: UserType.participant);
    }
  }

  @override
  Future<void> clearAuthenticationData() async {
    await localDataSource.clearAuthData();
  }
}
