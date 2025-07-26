import 'package:event_reg/core/network/dio_client.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> loginParticipant(LoginRequest request);
  Future<LoginResponse> loginAdmin(LoginRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<LoginResponse> loginParticipant(LoginRequest request) async {
    try {
      final response = await dioClient.post(
        '/auth/participant/login',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to login participant: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponse> loginAdmin(LoginRequest request) async {
    try {
      final response = await dioClient.post(
        '/auth/admin/login',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to login admin: ${e.toString()}');
    }
  }
}
