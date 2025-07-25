import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/features/registration/data/models/participant.dart';

import '../datasource/dashboard_datasource.dart';
import '../datasource/dashboard_local_datasource.dart';
import '../models/dashboard_stats.dart';
import '../models/participant_dashboard.dart';
import '../models/session.dart';

abstract class DashboardRepository {
  Future<bool> checkInParticipant(String participantId);
  Future<bool> checkOutParticipant(String participantId);
  // Cache Management
  Future<void> clearCache();
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

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<bool> checkInParticipant(String participantId) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.checkInParticipant(participantId);
      } catch (e) {
        throw Exception('Failed to check in participant: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<bool> checkOutParticipant(String participantId) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.checkOutParticipant(participantId);
      } catch (e) {
        throw Exception('Failed to check out participant: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }

  @override
  Future<String> downloadConfirmationPdf(String participantId) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.downloadConfirmationPdf(participantId);
      } catch (e) {
        throw Exception('Failed to download confirmation PDF: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<Participant>> getAllParticipants({
    String? searchQuery,
    String? sessionFilter,
    String? statusFilter,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final participants = await remoteDataSource.getAllParticipants(
          searchQuery: searchQuery,
          sessionFilter: sessionFilter,
          statusFilter: statusFilter,
        );

        // Cache only if no filters applied (full list)
        if (searchQuery == null &&
            sessionFilter == null &&
            statusFilter == null) {
          await localDataSource.cacheParticipants(participants);
        }

        return participants;
      } catch (e) {
        // Fallback to cached data only if no filters
        if (searchQuery == null &&
            sessionFilter == null &&
            statusFilter == null) {
          final cachedParticipants = await localDataSource
              .getCachedParticipants();
          if (cachedParticipants.isNotEmpty) {
            return cachedParticipants;
          }
        }
        throw Exception('Failed to get participants: ${e.toString()}');
      }
    } else {
      if (searchQuery == null &&
          sessionFilter == null &&
          statusFilter == null) {
        final cachedParticipants = await localDataSource
            .getCachedParticipants();
        if (cachedParticipants.isNotEmpty) {
          return cachedParticipants;
        }
      }
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<Session>> getAllSessions() async {
    if (await networkInfo.isConnected) {
      try {
        final sessions = await remoteDataSource.getAllSessions();
        await localDataSource.cacheSessions(sessions);
        return sessions;
      } catch (e) {
        // Fallback to cached data
        final cachedSessions = await localDataSource.getCachedSessions();
        if (cachedSessions.isNotEmpty) {
          return cachedSessions;
        }
        throw Exception('Failed to get sessions: ${e.toString()}');
      }
    } else {
      final cachedSessions = await localDataSource.getCachedSessions();
      if (cachedSessions.isNotEmpty) {
        return cachedSessions;
      }
      throw Exception('No internet connection and no cached data available');
    }
  }

  @override
  Future<Map<String, dynamic>> getAttendanceAnalytics() async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.getAttendanceAnalytics();
      } catch (e) {
        throw Exception('Failed to get attendance analytics: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    if (await networkInfo.isConnected) {
      try {
        final stats = await remoteDataSource.getDashboardStats();
        await localDataSource.cacheDashboardStats(stats);
        return stats;
      } catch (e) {
        // Fallback to cached data
        final cachedStats = await localDataSource.getCachedDashboardStats();
        if (cachedStats != null) {
          return cachedStats;
        }
        throw Exception('Failed to get dashboard stats: ${e.toString()}');
      }
    } else {
      final cachedStats = await localDataSource.getCachedDashboardStats();
      if (cachedStats != null) {
        return cachedStats;
      }
      throw Exception('No internet connection and no cached data available');
    }
  }

  @override
  Future<ParticipantDashboard> getParticipantDashboard(String email) async {
    if (await networkInfo.isConnected) {
      try {
        final dashboard = await remoteDataSource.getParticipantDashboard(email);
        await localDataSource.cacheParticipantDashboard(email, dashboard);
        return dashboard;
      } catch (e) {
        // Fallback to cached data
        final cachedDashboard = await localDataSource
            .getCachedParticipantDashboard(email);
        if (cachedDashboard != null) {
          return cachedDashboard;
        }
        throw Exception('Failed to get participant dashboard: ${e.toString()}');
      }
    } else {
      final cachedDashboard = await localDataSource
          .getCachedParticipantDashboard(email);
      if (cachedDashboard != null) {
        return cachedDashboard;
      }
      throw Exception('No internet connection and no cached data available');
    }
  }

  @override
  Future<bool> updateParticipantInfo(
    String participantId,
    Map<String, dynamic> updateData,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.updateParticipantInfo(
          participantId,
          updateData,
        );
      } catch (e) {
        throw Exception('Failed to update participant info: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }
}
