import 'attendance_stats.dart';
import 'participant_stats.dart';
import 'session_summary.dart';

class EventReport {
  final int eventId;
  final String eventTitle;
  final ParticipantStats participantStats;
  final AttendanceStats attendanceStats;
  final List<SessionSummary> sessions;

  EventReport({
    required this.eventId,
    required this.eventTitle,
    required this.participantStats,
    required this.attendanceStats,
    required this.sessions,
  });

  factory EventReport.fromJson(Map<String, dynamic> json) {
    return EventReport(
      eventId: json['event_id'] ?? 0,
      eventTitle: json['event_title'] ?? '',
      participantStats: ParticipantStats.fromJson(json['participant_stats'] ?? {}),
      attendanceStats: AttendanceStats.fromJson(json['attendance_stats'] ?? {}),
      sessions: (json['sessions'] as List? ?? [])
          .map((session) => SessionSummary.fromJson(session))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_title': eventTitle,
      'participant_stats': participantStats.toJson(),
      'attendance_stats': attendanceStats.toJson(),
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }

  double get overallAttendanceRate => 
    participantStats.approved > 0 ? (attendanceStats.totalAttendance / participantStats.approved) * 100 : 0.0;

  @override
  String toString() {
    return 'EventReport(eventId: $eventId, eventTitle: $eventTitle, sessionsCount: ${sessions.length})';
  }
}

