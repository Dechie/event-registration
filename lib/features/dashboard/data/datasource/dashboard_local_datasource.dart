import 'dart:convert';

import 'package:event_reg/features/registration/data/models/participant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_stats.dart';
import '../models/participant_dashboard.dart';
import '../models/session.dart';

abstract class DashboardLocalDataSource {
  Future<void> cacheDashboardStats(DashboardStats stats);
  Future<DashboardStats?> getCachedDashboardStats();
  Future<void> cacheParticipantDashboard(
    String email,
    ParticipantDashboard dashboard,
  );
  Future<ParticipantDashboard?> getCachedParticipantDashboard(String email);
  Future<void> cacheSessions(List<Session> sessions);
  Future<List<Session>> getCachedSessions();
  Future<void> cacheParticipants(List<Participant> participants);
  Future<List<Participant>> getCachedParticipants();
  Future<void> clearCache();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _dashboardStatsKey = 'dashboard_stats';
  static const String _participantDashboardKey = 'participant_dashboard_';
  static const String _sessionsKey = 'sessions';
  static const String _participantsKey = 'dashboard_participants';

  DashboardLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheDashboardStats(DashboardStats stats) async {
    await sharedPreferences.setString(
      _dashboardStatsKey,
      jsonEncode(stats.toJson()),
    );
  }

  @override
  Future<DashboardStats?> getCachedDashboardStats() async {
    final jsonString = sharedPreferences.getString(_dashboardStatsKey);
    if (jsonString != null) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DashboardStats.fromJson(json);
    }
    return null;
  }

  @override
  Future<void> cacheParticipantDashboard(
    String email,
    ParticipantDashboard dashboard,
  ) async {
    await sharedPreferences.setString(
      '$_participantDashboardKey$email',
      jsonEncode(dashboard.toJson()),
    );
  }

  @override
  Future<ParticipantDashboard?> getCachedParticipantDashboard(
    String email,
  ) async {
    final jsonString = sharedPreferences.getString(
      '$_participantDashboardKey$email',
    );
    if (jsonString != null) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ParticipantDashboard.fromJson(json);
    }
    return null;
  }

  @override
  Future<void> cacheSessions(List<Session> sessions) async {
    final jsonString = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await sharedPreferences.setString(_sessionsKey, jsonString);
  }

  @override
  Future<List<Session>> getCachedSessions() async {
    final jsonString = sharedPreferences.getString(_sessionsKey);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Session.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheParticipants(List<Participant> participants) async {
    final jsonString = jsonEncode(participants.map((p) => p.toJson()).toList());
    await sharedPreferences.setString(_participantsKey, jsonString);
  }

  @override
  Future<List<Participant>> getCachedParticipants() async {
    final jsonString = sharedPreferences.getString(_participantsKey);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Participant.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences.getKeys().where(
      (key) =>
          key.startsWith(_participantDashboardKey) ||
          key == _dashboardStatsKey ||
          key == _sessionsKey ||
          key == _participantsKey,
    );

    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
}
