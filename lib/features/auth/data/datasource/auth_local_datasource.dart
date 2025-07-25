import 'package:event_reg/features/splash/data/models/auth_status.dart'
    show AuthStatus, UserType;
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<AuthStatus> getAuthStatus();
  Future<void> saveAuthStatus(AuthStatus authStatus);
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _authTokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';
  static const String _userEmailKey = 'user_email';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AuthStatus> getAuthStatus() async {
    final token = sharedPreferences.getString(_authTokenKey);
    final userTypeString = sharedPreferences.getString(_userTypeKey);
    final email = sharedPreferences.getString(_userEmailKey);

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
      await sharedPreferences.setString(_authTokenKey, authStatus.token!);
    }
    await sharedPreferences.setString(
      _userTypeKey,
      authStatus.userType.toString(),
    );
    if (authStatus.email != null) {
      await sharedPreferences.setString(_userEmailKey, authStatus.email!);
    }
  }

  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove(_authTokenKey);
    await sharedPreferences.remove(_userTypeKey);
    await sharedPreferences.remove(_userEmailKey);
  }
}
