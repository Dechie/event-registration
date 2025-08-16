// lib/features/attendance_report/data/models/attendance_report.dart
import 'aggregated_stats.dart';
import 'attendance_history.dart';
import 'attendance_trend.dart';
import 'location_stats.dart';
import 'round_metrics.dart';

class AttendanceReport {
  final int participantId;
  final String participantName;
  final List<AttendanceHistory> attendanceHistory;
  final AggregatedStats aggregatedStats;
  final List<RoundMetrics> roundMetrics;
  final List<LocationStats> locationStats;
  final List<AttendanceTrend> attendanceTrend;

  AttendanceReport({
    required this.participantId,
    required this.participantName,
    required this.attendanceHistory,
    required this.aggregatedStats,
    required this.roundMetrics,
    required this.locationStats,
    required this.attendanceTrend,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    return AttendanceReport(
      participantId: json['participant_id'] ?? 0,
      participantName: json['participant_name'] ?? '',
      attendanceHistory:
          (json['attendance_history'] as List<dynamic>?)
              ?.map(
                (item) =>
                    AttendanceHistory.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      aggregatedStats: AggregatedStats.fromJson(json['aggregated_stats'] ?? {}),
      roundMetrics:
          (json['round_metrics'] as List<dynamic>?)
              ?.map(
                (item) => RoundMetrics.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      locationStats:
          (json['location_stats'] as List<dynamic>?)
              ?.map(
                (item) => LocationStats.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      attendanceTrend:
          (json['attendance_trend'] as List<dynamic>?)
              ?.map(
                (item) =>
                    AttendanceTrend.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
