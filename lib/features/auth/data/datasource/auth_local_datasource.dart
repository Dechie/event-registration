import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/auth/data/models/login/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheUserData(LoginResponse loginResponse);
  Future<void> clearUserData();
  Future<LoginResponse?> getCachedUserData();
  Future<bool> isAuthenticated();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final UserDataService userDataService;
  final SharedPreferences sharedPrefs;

  AuthLocalDatasourceImpl({
    required this.userDataService,
    required this.sharedPrefs,
  });

  @override
  Future<void> cacheUserData(LoginResponse loginResponse) async {
    try {
      await userDataService.saveLoginData(loginResponse);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: "Failed to cache user data",
        code: "CACHE_WRITE_ERROR",
      );
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await userDataService.clearAllData();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: "Failed to clear user data",
        code: "CACHE_CLEAR_ERROR",
      );
    }
  }

  @override
  Future<LoginResponse?> getCachedUserData() async {
    try {
      return await userDataService.getLoginData();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: "Failed to retreive cached user data",
        code: 'CACHE_READ_ERROR',
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await userDataService.isAuthenticated();
    } catch (e) {
      return false;
    }
  }
}
