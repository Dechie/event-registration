// lib/features/reports/data/models/session_report.dart
import 'attendance_stats.dart';
import 'location_report.dart';

class SessionReport {
  final int sessionId;
  final String sessionName;
  final int eventId;
  final AttendanceStats overallStats;
  final List<LocationReport> locations;

  SessionReport({
    required this.sessionId,
    required this.sessionName,
    required this.eventId,
    required this.overallStats,
    required this.locations,
  });

  factory SessionReport.fromJson(Map<String, dynamic> json) {
    return SessionReport(
      sessionId: json['session_id'] ?? 0,
      sessionName: json['session_name'] ?? '',
      eventId: json['event_id'] ?? 0,
      overallStats: AttendanceStats.fromJson(json['overall_stats'] ?? {}),
      locations: (json['locations'] as List? ?? [])
          .map((location) => LocationReport.fromJson(location))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'session_name': sessionName,
      'event_id': eventId,
      'overall_stats': overallStats.toJson(),
      'locations': locations.map((location) => location.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'SessionReport(sessionId: $sessionId, sessionName: $sessionName, locationsCount: ${locations.length})';
  }
}

