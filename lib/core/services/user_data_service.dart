import 'dart:convert';

import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/features/auth/data/models/login/login_response.dart';
import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static const String _userDataKey = "USER_DATA";
  static const String _tokenKey = "AUTH_TOKEN";
  static const String _userIdKey = "USER_ID";
  static const String _userEmailKey = "USER_EMAIL";
  static const String _isLoggedInKey = "IS_LOGGED_IN";
  static const String _userTypeKey = 'USER_TYPE';
  final SharedPreferences _sharedPreferences;

  UserDataService(this._sharedPreferences);

  // clear all user data (logout)
  Future<void> clearAllData() async {
    try {
      await Future.wait([
        _sharedPreferences.remove(_userDataKey),
        _sharedPreferences.remove(_tokenKey),
        _sharedPreferences.remove(_userIdKey),
        _sharedPreferences.remove(_userEmailKey),
        _sharedPreferences.remove(_userTypeKey),
        _sharedPreferences.setBool(_isLoggedInKey, false),
      ]);
    } catch (e) {
      throw CacheException(
        message: "Failed to clear user data",
        code: "CACHE_CLEAR_ERROR",
      );
    }
  }

  // get auth token
  Future<String?> getAuthToken() async {
    try {
      return _sharedPreferences.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // get current user data
  Future<User?> getCurrentUser() async {
    try {
      final loginData = await getLoginData();
      return loginData?.user;
    } catch (e) {
      return null;
    }
  }

  // get complete login response data
  Future<LoginResponse?> getLoginData() async {
    try {
      final userDataJson = _sharedPreferences.getString(_userDataKey);
      debugPrint("the found userDataJson: $userDataJson");

      if (userDataJson != null) {
        debugPrint(userDataJson);
        final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
        debugPrint("userDatamap parsed: ");
        for (var entry in userDataMap.entries) {
          if (entry.key == "user") continue;
          debugPrint("<${entry.key}>");
          debugPrint("    ${entry.value}");
          debugPrint("</${entry.key}>");
        }
        return LoginResponse.fromJson(userDataMap);
      }
      return null;
    } catch (e) {
      throw CacheException(
        message: "Failed to retreive login data",
        code: "CACHE_READ_ERROR",
      );
    }
  }

  // get user data as map for easy access
  Future<Map<String, dynamic>?> getUserDataMap() async {
    try {
      final user = await getCurrentUser();
      return user?.toJson();
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      return _sharedPreferences.getString(_userEmailKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      return _sharedPreferences.getString(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserType() async {
    try {
      return _sharedPreferences.getString(_userTypeKey);
    } catch (e) {
      return null;
    }
  }

  // check if user has specific role/type
  Future<bool> hasUserType(String userType) async {
    try {
      final currentUserType = await getUserType();
      return currentUserType?.toLowerCase() == userType.toLowerCase();
    } catch (e) {
      return false;
    }
  }

  // check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final isLoggedIn = _sharedPreferences.getBool(_isLoggedInKey) ?? false;
      final user = await getCurrentUser();
      return isLoggedIn && user != null;
    } catch (e) {
      return false;
    }
  }

  // save complete login response data
  Future<void> saveLoginData(LoginResponse loginResponse) async {
    try {
      final userDataJson = jsonEncode(loginResponse.toJson());
      debugPrint("SAVING USER DATA: $userDataJson");

      await Future.wait([
        _sharedPreferences.setString(_userIdKey, loginResponse.id),
        _sharedPreferences.setString(_userDataKey, userDataJson),
        _sharedPreferences.setString(_tokenKey, loginResponse.token),
        _sharedPreferences.setString(_userIdKey, loginResponse.user.id),
        _sharedPreferences.setString(_userEmailKey, loginResponse.user.email),
        _sharedPreferences.setString(_userTypeKey, loginResponse.user.userType),
        _sharedPreferences.setBool(_isLoggedInKey, true),
      ]);
    } catch (e) {
      throw CacheException(
        message: "Failed to save login data",
        code: "CACHE_WRITE_ERROR",
      );
    }
  }

  // update user data
  Future<void> updateUserData(User updatedUser) async {
    try {
      final currentLoginData = await getLoginData();

      if (currentLoginData != null) {
        final updatedLoginData = currentLoginData.copyWith(user: updatedUser);
        await saveLoginData(updatedLoginData);
      } else {
        throw CacheException(
          message: "No existing login data to update",
          code: 'NO_LOGIN_DATA',
        );
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: "Failed to update user data",
        code: "CACHE_UPDATE_ERROR",
      );
    }
  }
}
