// lib/features/reports/data/models/attendance_stats.dart
class AttendanceStats {
  final int totalAttendance;
  final int present;
  final int lateComing;
  final int absent;

  AttendanceStats({
    required this.totalAttendance,
    required this.present,
    required this.lateComing,
    required this.absent,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalAttendance: json['total_attendance'] ?? json['total'] ?? 0,
      present: json['present'] ?? 0,
      lateComing: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }

  double get absentRate =>
      totalAttendance > 0 ? (absent / totalAttendance) * 100 : 0.0;

  double get lateRate =>
      totalAttendance > 0 ? (lateComing / totalAttendance) * 100 : 0.0;
  double get presentRate =>
      totalAttendance > 0 ? (present / totalAttendance) * 100 : 0.0;
  Map<String, dynamic> toJson() {
    return {
      'total_attendance': totalAttendance,
      'present': present,
      'late': lateComing,
      'absent': absent,
    };
  }

  @override
  String toString() {
    return 'AttendanceStats(total: $totalAttendance, present: $present, late: $lateComing, absent: $absent)';
  }
}
