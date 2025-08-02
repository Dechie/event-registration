// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../constants/app_urls.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class DioClient {
  late final Dio dio;
  final UserDataService? userDataService;

  DioClient(Dio dioInstance, {this.userDataService}) {
    dio = dioInstance;

    // Configure base options
    dio.options = BaseOptions(
      baseUrl: AppUrls.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add Interceptors for authentication
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint("🚀 Request: ${options.method} ${options.uri}");
          debugPrint("📤 Data: ${options.data}");

          // Handle explicit token from options
          if (options.extra["token"] != null) {
            final token = options.extra["token"];
            options.headers["Authorization"] = "Bearer $token";
            debugPrint("🔑 Using explicit token");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            "📥 Response: ${response.statusCode} ${response.requestOptions.uri}",
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint(
            "❌ Error: ${e.response?.statusCode} ${e.requestOptions.uri}",
          );
          debugPrint("❌ Error message: ${e.message}");

          if (e.response?.statusCode == 401) {
            debugPrint("🚨 Unauthorized! Token might be expired.");
          }
          return handler.next(e);
        },
      ),
    );

    // Add logging interceptor (only in debug mode)
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  Future<Response> delete(String path, {String? token}) async {
    try {
      return await dio.delete(path, options: Options(extra: {"token": token}));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError("Unexpected error: ${e.toString()}");
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParams ?? queryParameters,
        options: Options(extra: {"token": token}),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError("Unexpected error: ${e.toString()}");
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    String? token,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        options: options ?? Options(extra: {"token": token}),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError("Unexpected error: ${e.toString()}");
    }
  }

  Future<Response> put(String path, {dynamic data, String? token}) async {
    try {
      return await dio.put(
        path,
        data: data,
        options: Options(extra: {"token": token}),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError("Unexpected error: ${e.toString()}");
    }
  }

  /// Handle Dio errors and convert them to ApiError
  ApiError _handleDioError(DioException error) {
    String message = "An unknown error occurred";
    int? statusCode = error.response?.statusCode;

    // Extract message from response
    if (error.response?.data != null) {
      if (error.response!.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        message = data["message"] ?? data["error"] ?? message;
      } else if (error.response!.data is String) {
        message = error.response!.data;
      }
    }

    // Handle different error types
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiError("Connection timed out", statusCode: 408);
      case DioExceptionType.sendTimeout:
        return ApiError("Request send timed out", statusCode: 408);
      case DioExceptionType.receiveTimeout:
        return ApiError("Response receive timed out", statusCode: 408);
      case DioExceptionType.badResponse:
        return ApiError(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiError("Request was cancelled");
      case DioExceptionType.connectionError:
        return ApiError(
          "Connection error. Please check your internet connection",
        );
      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('SocketException') == true) {
          return ApiError("No internet connection");
        }
        return ApiError(message, statusCode: statusCode ?? 500);
    }
  }
}
