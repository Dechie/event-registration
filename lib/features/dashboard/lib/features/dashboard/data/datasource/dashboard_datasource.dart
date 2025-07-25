import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/registration/data/models/participant.dart';

import '../models/dashboard_stats.dart';
import '../models/participant_dashboard.dart';
import '../models/session.dart';

abstract class DashboardRemoteDataSource {
  Future<bool> checkInParticipant(String participantId);
  Future<bool> checkOutParticipant(String participantId);
  Future<String> downloadConfirmationPdf(String participantId);
  Future<List<Participant>> getAllParticipants({
    String? searchQuery,
    String? sessionFilter,
    String? statusFilter,
  });
  Future<List<Session>> getAllSessions();
  Future<Map<String, dynamic>> getAttendanceAnalytics();

  // Admin Dashboard
  Future<DashboardStats> getDashboardStats();
  // Participant Dashboard
  Future<ParticipantDashboard> getParticipantDashboard(String email);
  Future<bool> updateParticipantInfo(
    String participantId,
    Map<String, dynamic> updateData,
  );
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<bool> checkInParticipant(String participantId) async {
    try {
      final response = await dioClient.post(
        '/admin/participants/$participantId/checkin',
        data: {
          'checkedIn': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to check in participant: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkOutParticipant(String participantId) async {
    try {
      final response = await dioClient.post(
        '/admin/participants/$participantId/checkout',
        data: {
          'checkedIn': false,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to check out participant: ${e.toString()}');
    }
  }

  @override
  Future<String> downloadConfirmationPdf(String participantId) async {
    try {
      final response = await dioClient.get(
        '/participants/$participantId/confirmation-pdf',
      );
      return response.data['downloadUrl'] as String;
    } catch (e) {
      throw Exception('Failed to get confirmation PDF: ${e.toString()}');
    }
  }

  @override
  Future<List<Participant>> getAllParticipants({
    String? searchQuery,
    String? sessionFilter,
    String? statusFilter,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (sessionFilter != null && sessionFilter.isNotEmpty) {
        queryParams['session'] = sessionFilter;
      }
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['status'] = statusFilter;
      }

      final response = await dioClient.get(
        '/admin/participants',
        queryParams: queryParams,
      );

      final List<dynamic> participantsJson = response.data['participants'];
      return participantsJson
          .map((json) => Participant.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get participants: ${e.toString()}');
    }
  }

  @override
  Future<List<Session>> getAllSessions() async {
    try {
      final response = await dioClient.get('/admin/sessions');
      final List<dynamic> sessionsJson = response.data['sessions'];
      return sessionsJson.map((json) => Session.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get sessions: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getAttendanceAnalytics() async {
    try {
      final response = await dioClient.get('/admin/analytics/attendance');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get attendance analytics: ${e.toString()}');
    }
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await dioClient.get('/admin/dashboard/stats');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get dashboard stats: ${e.toString()}');
    }
  }

  @override
  Future<ParticipantDashboard> getParticipantDashboard(String email) async {
    try {
      final response = await dioClient.get(
        '/participants/dashboard',
        queryParams: {'email': email},
      );
      return ParticipantDashboard.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get participant dashboard: ${e.toString()}');
    }
  }

  @override
  Future<bool> updateParticipantInfo(
    String participantId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await dioClient.put(
        '/participants/$participantId',
        data: updateData,
      );
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to update participant info: ${e.toString()}');
    }
  }
}
