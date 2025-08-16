// lib/features/attendance_report/data/models/aggregated_stats.dart
class AggregatedStats {
  final int totalSessions;
  final int totalRounds;
  final int present;
  final int late;
  final int absent;
  final double attendanceRatePercent;
  final double absenceRatePercent;

  AggregatedStats({
    required this.totalSessions,
    required this.totalRounds,
    required this.present,
    required this.late,
    required this.absent,
    required this.attendanceRatePercent,
    required this.absenceRatePercent,
  });

  factory AggregatedStats.fromJson(Map<String, dynamic> json) {
    return AggregatedStats(
      totalSessions: json['total_sessions'] ?? 0,
      totalRounds: json['total_rounds'] ?? 0,
      present: json['present'] ?? 0,
      late: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
      attendanceRatePercent: (json['attendance_rate_percent'] ?? 0).toDouble(),
      absenceRatePercent: (json['absence_rate_percent'] ?? 0).toDouble(),
    );
  }
}

