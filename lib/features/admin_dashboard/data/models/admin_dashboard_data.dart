// lib/features/admin_dashboard/data/models/admin_dashboard_data.dart

import 'package:equatable/equatable.dart';

class AdminDashboardData extends Equatable {
  final int eventsCount;
  final int sessionsCount;
  final int participantsCount;
  final double attendanceRate;
  final int activeCouponsCount;
  final int pendingApprovalsCount;
  final List<UpcomingEvent> upcomingEvents;
  final List<AttendanceBySession> attendanceBySession;
  final GenderStats genderStats;
  final Map<String, int> occupationStats;

  const AdminDashboardData({
    required this.eventsCount,
    required this.sessionsCount,
    required this.participantsCount,
    required this.attendanceRate,
    required this.activeCouponsCount,
    required this.pendingApprovalsCount,
    required this.upcomingEvents,
    required this.attendanceBySession,
    required this.genderStats,
    required this.occupationStats,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      eventsCount: json['events_count'] ?? 0,
      sessionsCount: json['sessions_count'] ?? 0,
      participantsCount: json['participants_count'] ?? 0,
      attendanceRate: (json['attendance_rate'] ?? 0).toDouble(),
      activeCouponsCount: json['active_coupons_count'] ?? 0,
      pendingApprovalsCount: json['pending_approvals_count'] ?? 0,
      upcomingEvents: (json['upcoming_events'] as List<dynamic>? ?? [])
          .map((e) => UpcomingEvent.fromJson(e))
          .toList(),
      attendanceBySession: (json['attendanceBySession'] as List<dynamic>? ?? [])
          .map((e) => AttendanceBySession.fromJson(e))
          .toList(),
      genderStats: GenderStats.fromJson(json['genderStats'] ?? {}),
      occupationStats: Map<String, int>.from(json['occupationStats'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        eventsCount,
        sessionsCount,
        participantsCount,
        attendanceRate,
        activeCouponsCount,
        pendingApprovalsCount,
        upcomingEvents,
        attendanceBySession,
        genderStats,
        occupationStats,
      ];
}

class UpcomingEvent extends Equatable {
  final int id;
  final String title;
  final String startTime;

  const UpcomingEvent({
    required this.id,
    required this.title,
    required this.startTime,
  });

  factory UpcomingEvent.fromJson(Map<String, dynamic> json) {
    return UpcomingEvent(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      startTime: json['start_time'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, startTime];
}

class AttendanceBySession extends Equatable {
  final String session;
  final int attended;
  final String startTime;

  const AttendanceBySession({
    required this.session,
    required this.attended,
    required this.startTime,
  });

  factory AttendanceBySession.fromJson(Map<String, dynamic> json) {
    return AttendanceBySession(
      session: json['session'] ?? '',
      attended: json['attended'] ?? 0,
      startTime: json['start_time'] ?? '',
    );
  }

  @override
  List<Object?> get props => [session, attended, startTime];
}

class GenderStats extends Equatable {
  final int male;
  final int female;

  const GenderStats({
    required this.male,
    required this.female,
  });

  factory GenderStats.fromJson(Map<String, dynamic> json) {
    return GenderStats(
      male: json['male'] ?? 0,
      female: json['female'] ?? 0,
    );
  }

  int get total => male + female;

  @override
  List<Object?> get props => [male, female];
}