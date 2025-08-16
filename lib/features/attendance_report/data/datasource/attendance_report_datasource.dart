// lib/features/attendance_report/data/datasource/attendance_report_datasource.dart
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/attendance_report/data/models/attendance_report.dart';
import 'package:flutter/material.dart' show debugPrint;

abstract class AttendanceReportDataSource {
  Future<AttendanceReport> getMyAttendanceReport();
}

class AttendanceReportDataSourceImpl implements AttendanceReportDataSource {
  final DioClient dioClient;
  final UserDataService userDataService;

  AttendanceReportDataSourceImpl({
    required this.dioClient,
    required this.userDataService,
  });

  @override
  Future<AttendanceReport> getMyAttendanceReport() async {
    try {
      debugPrint('🔍 Fetching attendance report...');
      
      // Get auth token
      final token = await userDataService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Make API call
      final response = await dioClient.get(
        '/my-attendance-report',
        token: token,
      );

      debugPrint('✅ Attendance report fetched successfully');
      debugPrint('📊 Response data: ${response.data}');

      // Parse the response
      final attendanceReport = AttendanceReport.fromJson(response.data);
      
      return attendanceReport;
    } catch (e) {
      debugPrint('❌ Error fetching attendance report: $e');
      rethrow;
    }
  }
}