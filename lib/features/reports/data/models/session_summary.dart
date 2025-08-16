// lib/features/reports/data/models/session_summary.dart
import 'attendance_stats.dart';

class SessionSummary {
  final int sessionId;
  final String sessionName;
  final int totalAttendance;
  final int present;
  final int late;
  final int absent;

  SessionSummary({
    required this.sessionId,
    required this.sessionName,
    required this.totalAttendance,
    required this.present,
    required this.late,
    required this.absent,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      sessionId: json['session_id'] ?? 0,
      sessionName: json['session_name'] ?? '',
      totalAttendance: json['total_attendance'] ?? 0,
      present: json['present'] ?? 0,
      late: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }

  AttendanceStats get attendanceStats => AttendanceStats(
    totalAttendance: totalAttendance,
    present: present,
    lateComing: late,
    absent: absent,
  );

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'session_name': sessionName,
      'total_attendance': totalAttendance,
      'present': present,
      'late': late,
      'absent': absent,
    };
  }

  @override
  String toString() {
    return 'SessionSummary(sessionId: $sessionId, sessionName: $sessionName, totalAttendance: $totalAttendance)';
  }
}
