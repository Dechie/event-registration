// lib/features/admin_dashboard/data/datasource/admin_dashboard_datasource.dart

import 'package:event_reg/core/network/dio_client.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/user_data_service.dart';
import '../models/admin_dashboard_data.dart';
import 'package:event_reg/features/landing/data/models/event_session.dart';

abstract class AdminDashboardDataSource {
  Future<AdminDashboardData> getDashboardData();
  Future<List<EventSession>> getEventSessions();
}

class AdminDashboardDataSourceImpl implements AdminDashboardDataSource {
  final UserDataService userDataService;
  final DioClient dioClient;

  AdminDashboardDataSourceImpl({
    required this.dioClient,
    required this.userDataService,
  });

  @override
  Future<AdminDashboardData> getDashboardData() async {
    try {
      final token = await userDataService.getAuthToken();
      final response = await dioClient.get(
        '/org-admin/dashboard',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final dashboardData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        return AdminDashboardData.fromJson(dashboardData);
      } else {
        final responseData = response.data;
        final errorMessage = responseData is Map<String, dynamic>
            ? responseData["message"] ?? "Loading dashboard data failed"
            : "Loading Dashboard data failed";
        final errorCode = responseData is Map<String, dynamic>
            ? responseData["code"] ?? "LOADING_DATA_FAILED"
            : "LOADING_DATA_FAILED";
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: "An unexpected error occureed during loading dashboard data",
        code: "UNEXPECTED_DASHBOARD_ERROR",
      );
    }
  }

  @override
  Future<List<EventSession>> getEventSessions() async {
    try {
      final token = await userDataService.getAuthToken();
      final response = await dioClient.get(
        '/admin/sessions',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final sessionsData = data is Map<String, dynamic>
            ? (data["data"] ?? data)
            : data;

        if (sessionsData is List) {
          return sessionsData
              .map((sessionJson) => EventSession.fromJson(sessionJson))
              .toList();
        } else if (sessionsData is Map<String, dynamic> && sessionsData.containsKey('sessions')) {
          final sessionsList = sessionsData['sessions'] as List;
          return sessionsList
              .map((sessionJson) => EventSession.fromJson(sessionJson))
              .toList();
        }
        
        return [];
      } else {
        final responseData = response.data;
        final errorMessage = responseData is Map<String, dynamic>
            ? responseData["message"] ?? "Loading sessions failed"
            : "Loading sessions failed";
        final errorCode = responseData is Map<String, dynamic>
            ? responseData["code"] ?? "LOADING_SESSIONS_FAILED"
            : "LOADING_SESSIONS_FAILED";
        throw ServerException(message: errorMessage, code: errorCode);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: "An unexpected error occurred while loading sessions",
        code: "UNEXPECTED_SESSIONS_ERROR",
      );
    }
  }
}
