// lib/features/attendance_report/data/models/attendance_history.dart
class AttendanceHistory {
  final int eventId;
  final String eventName;
  final int sessionId;
  final String sessionName;
  final int locationId;
  final int attendanceRoundId;
  final String roundName;
  final String status;
  final String? checkedInAt;
  final String? checkedOutAt;
  final double? durationMinutes;

  AttendanceHistory({
    required this.eventId,
    required this.eventName,
    required this.sessionId,
    required this.sessionName,
    required this.locationId,
    required this.attendanceRoundId,
    required this.roundName,
    required this.status,
    this.checkedInAt,
    this.checkedOutAt,
    this.durationMinutes,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      eventId: json['event_id'] ?? 0,
      eventName: json['event_name'] ?? '',
      sessionId: json['session_id'] ?? 0,
      sessionName: json['session_name'] ?? '',
      locationId: json['location_id'] ?? 0,
      attendanceRoundId: json['attendance_round_id'] ?? 0,
      roundName: json['round_name'] ?? '',
      status: json['status'] ?? '',
      checkedInAt: json['checked_in_at'],
      checkedOutAt: json['checked_out_at'],
      durationMinutes: json['duration_minutes']?.toDouble(),
    );
  }

  String get formattedDuration {
    if (durationMinutes == null) return 'N/A';
    final hours = (durationMinutes! / 60).floor();
    final minutes = (durationMinutes! % 60).round();
    return '${hours}h ${minutes}m';
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      default:
        return status;
    }
  }
}

