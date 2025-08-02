import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:dio/dio.dart';

abstract class ProfileRemoteDatasource {
  Future<User> getProfile(String token);
  Future<Map<String, dynamic>> createProfile({
    required String token,
    required Map<String, dynamic> profileData,
  });
  Future<User> updateProfile({
    required String token,
    required Map<String, dynamic> profileData,
  });
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final DioClient dioClient;
  ProfileRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<User> getProfile(String token) async {
    try {
      final response = await dioClient.get("/me", token: token);

      if (response.statusCode == 200) {
        final data = response.data["data"] ?? response.data;
        return User.fromJson(data);
      } else {
        throw ServerException(
          message: response.data["message"] ?? "Failed to get profile",
          code: response.data["code"] ?? "GET_PROFILE_FAILED",
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, "GET_PROFILE_ERROR");
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: "Failed to get profile",
        code: "GET_PROFILE_ERROR",
      );
    }
  }

  @override
  Future<Map<String, dynamic>> createProfile({
    required String token,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // Create FormData for file upload support
      final formData = FormData();
      
      // Add text fields
      profileData.forEach((key, value) {
        if (value != null && key != 'photo') {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Handle photo upload if present
      if (profileData['photoPath'] != null) {
        final photoPath = profileData['photoPath'] as String;
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(photoPath),
          ),
        );
      }

      final response = await dioClient.post(
        "/participant/profile",
        data: formData,
        token: token,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          extra: {"token": token},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'message': data["message"] ?? "Profile created successfully",
          'participant': data["participant"],
        };
      } else {
        throw ServerException(
          message: response.data["message"] ?? "Failed to create profile",
          code: response.data["code"] ?? 'CREATE_PROFILE_FAILED',
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, "CREATE_PROFILE_ERROR");
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: "Failed to create profile",
        code: "CREATE_PROFILE_ERROR",
      );
    }
  }

  @override
  Future<User> updateProfile({
    required String token,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await dioClient.put(
        "/me",
        data: profileData,
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data["data"] ?? response.data;
        return User.fromJson(data);
      } else {
        throw ServerException(
          message: response.data["message"] ?? "Failed to update profile",
          code: response.data["code"] ?? 'UPDATE_PROFILE_FAILED',
        );
      }
    } on ApiError catch (e) {
      _handleApiError(e, "UPDATE_PROFILE_ERROR");
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: "Failed to update profile",
        code: "UPDATE_PROFILE_ERROR",
      );
    }
  }

  Never _handleApiError(ApiError error, String defaultCode) {
    if (error.statusCode != null) {
      switch (error.statusCode!) {
        case 400:
          throw ValidationException(
            message: error.message,
            code: "VALIDATION_ERROR",
          );
        case 401:
          throw AuthenticationException(
            message: error.message,
            code: "UNAUTHORIZED",
          );
        case 403:
          throw AuthorizationException(
            message: error.message,
            code: 'FORBIDDEN',
          );
        case 404:
          throw ServerException(message: error.message, code: 'NOT_FOUND');
        case 409:
          throw ValidationException(
            message: error.message,
            code: "PROFILE_ALREADY_EXISTS",
          );
        case 422:
          throw ValidationException(
            message: error.message,
            code: "VALIDATION_ERROR",
          );
        case 408:
          throw TimeoutException(message: error.message, code: "TIMEOUT_ERROR");
        case 500:
        default:
          throw ServerException(message: error.message, code: 'SERVER_ERROR');
      }
    } else {
      throw NetworkException(
        message: "Network error. Please check your connection.",
        code: "NETWORK_ERROR",
      );
    }
  }
}