import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/injection_container.dart';
import 'package:flutter/material.dart';

class TokenHelper {
  static AuthLocalDataSource get _localDataSource => sl<AuthLocalDataSource>();

  static Future<String?> getToken() async {
    try {
      final userData = await _localDataSource.getCachedUserData();
      return userData?.token;
    } catch (e) {
      debugPrint("couldn't fetch token: $e");
      return null;
    }
  }

  static Future<void> clearTokens() async {
    try {
      await _localDataSource.clearUserData();
    } catch (e) {
      //  
      debugPrint("clear user data failed: $e");
    }
  }
}
