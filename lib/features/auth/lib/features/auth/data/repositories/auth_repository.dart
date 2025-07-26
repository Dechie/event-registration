import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/features/auth/lib/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/features/auth/lib/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_reg/features/auth/lib/features/auth/data/models/login_response.dart';
import 'package:event_reg/features/splash/lib/features/splash/data/models/auth_status.dart';

import '../models/login_request.dart';

abstract class AuthRepository {
  Future<AuthStatus> getCurrentAuthStatus();
  Future<LoginResponse> loginAdmin(LoginRequest request);
  Future<LoginResponse> loginParticipant(LoginRequest request);
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<AuthStatus> getCurrentAuthStatus() async {
    return await localDataSource.getAuthStatus();
  }

  @override
  Future<LoginResponse> loginAdmin(LoginRequest request) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.loginAdmin(request);

        // Save authentication data locally
        await localDataSource.saveAuthStatus(
          AuthStatus(
            userType: UserType.admin,
            token: response.token,
            email: request.email,
          ),
        );

        return response;
      } catch (e) {
        throw Exception('Failed to login: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<LoginResponse> loginParticipant(LoginRequest request) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.loginParticipant(request);

        // Save authentication data locally
        await localDataSource.saveAuthStatus(
          AuthStatus(
            userType: UserType.participant,
            token: response.token,
            email: request.email,
          ),
        );

        return response;
      } catch (e) {
        throw Exception('Failed to login: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAuthData();
  }
}
