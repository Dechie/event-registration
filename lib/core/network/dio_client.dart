import 'package:dio/dio.dart';
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

  DioClient(Dio dioInstance) {
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
          if (options.extra["token"] != null) {
            final token = options.extra["token"];
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("Unauthorized! Token might be expired.");
            // Handle token refresh if needed
          }
          return handler.next(e);
        },
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
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
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParams,
        options: Options(extra: {"token": token}),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiError("Unexpected error: ${e.toString()}");
    }
  }

  Future<Response> post(String path, {dynamic data, String? token}) async {
    try {
      return await dio.post(
        path,
        data: data, // Remove jsonEncode here as Dio handles it
        options: Options(extra: {"token": token}),
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

  // Handle Dio errors
  ApiError _handleDioError(DioException error) {
    // Handle case where API returns message for failures
    if (error.response != null) {
      if (error.response!.data is Map<String, dynamic>) {
        return ApiError(
          error.response!.data["message"] ?? "An unknown error occurred!",
          statusCode: error.response!.statusCode,
        );
      } else if (error.response!.data is String) {
        return ApiError(
          error.response!.data,
          statusCode: error.response!.statusCode,
        );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiError("Connection timed out!", statusCode: 408);
      case DioExceptionType.sendTimeout:
        return ApiError("Request send timed out!", statusCode: 408);
      case DioExceptionType.receiveTimeout:
        return ApiError("Response receive timed out!", statusCode: 408);
      case DioExceptionType.badResponse:
        return ApiError(
          "Received an invalid response: ${error.response?.statusCode}",
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiError("Request was cancelled!");
      case DioExceptionType.unknown:
      default:
        return ApiError("Something went wrong!", statusCode: 500);
    }
  }
}
