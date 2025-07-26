import 'package:event_reg/features/splash/lib/features/splash/data/datasource/splash_datasource.dart';

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
      return await localDataSource.getAuthStatus();
    } catch (e) {
      return AuthStatus(userType: UserType.none);
    }
  }

  @override
  Future<void> clearAuthenticationData() async {
    await localDataSource.clearAuthData();
  }
}