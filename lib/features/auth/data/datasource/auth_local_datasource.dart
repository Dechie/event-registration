import 'dart:convert';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_reg/features/auth/data/models/login_response.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserData(LoginResponse loginResponse);
  Future<LoginResponse?> getCachedUserData();
  Future<void> clearUserData();
  Future<String?> getRefreshToken();
  Future<bool> isTokenValid();
  Future<void> setRememberMe(bool remember);
  Future<bool> getRememberMe();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _userDataKey = 'USER_DATA';
  static const String _tokenKey = 'AUTH_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';
  static const String _tokenExpiryKey = 'TOKEN_EXPIRY';
  static const String _rememberMeKey = 'REMEMBER_ME';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUserData(LoginResponse loginResponse) async {
    try {
      final userDataJson = jsonEncode(loginResponse.toJson());
      
      await Future.wait([
        sharedPreferences.setString(_userDataKey, userDataJson),
        sharedPreferences.setString(_tokenKey, loginResponse.token),
        if (loginResponse.refreshToken != null)
          sharedPreferences.setString(_refreshTokenKey, loginResponse.refreshToken!),
        sharedPreferences.setString(
          _tokenExpiryKey,
          loginResponse.expiresAt.toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user data',
        code: 'CACHE_WRITE_ERROR',
      );
    }
  }

  @override
  Future<LoginResponse?> getCachedUserData() async {
    try {
      final userDataJson = sharedPreferences.getString(_userDataKey);
      
      if (userDataJson != null) {
        final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
        return LoginResponse.fromJson(userDataMap);
      }
      
      return null;
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve cached user data',
        code: 'CACHE_READ_ERROR',
      );
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await Future.wait([
        sharedPreferences.remove(_userDataKey),
        sharedPreferences.remove(_tokenKey),
        sharedPreferences.remove(_refreshTokenKey),
        sharedPreferences.remove(_tokenExpiryKey),
        // Don't clear remember me preference
      ]);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear user data',
        code: 'CACHE_CLEAR_ERROR',
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return sharedPreferences.getString(_refreshTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get refresh token',
        code: 'CACHE_READ_ERROR',
      );
    }
  }

  @override
  Future<bool> isTokenValid() async {
    try {
      final tokenExpiryString = sharedPreferences.getString(_tokenExpiryKey);
      
      if (tokenExpiryString == null) {
        return false;
      }
      
      final tokenExpiry = DateTime.parse(tokenExpiryString);
      final now = DateTime.now();
      
      // Check if token expires within the next 5 minutes
      return tokenExpiry.isAfter(now.add(const Duration(minutes: 5)));
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setRememberMe(bool remember) async {
    try {
      await sharedPreferences.setBool(_rememberMeKey, remember);
    } catch (e) {
      throw CacheException(
        message: 'Failed to set remember me preference',
        code: 'CACHE_WRITE_ERROR',
      );
    }
  }

  @override
  Future<bool> getRememberMe() async {
    try {
      return sharedPreferences.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      return false;
    }
  }
}
