// lib/features/attendance_report/data/models/round_metrics.dart
class RoundMetrics {
  final int roundId;
  final String roundName;
  final int present;
  final int late;
  final int absent;
  final int missed;
  final double avgLatenessMinutes;

  RoundMetrics({
    required this.roundId,
    required this.roundName,
    required this.present,
    required this.late,
    required this.absent,
    required this.missed,
    required this.avgLatenessMinutes,
  });

  factory RoundMetrics.fromJson(Map<String, dynamic> json) {
    return RoundMetrics(
      roundId: json['round_id'] ?? 0,
      roundName: json['round_name'] ?? '',
      present: json['present'] ?? 0,
      late: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
      missed: json['missed'] ?? 0,
      avgLatenessMinutes: (json['avg_lateness_minutes'] ?? 0).toDouble(),
    );
  }

  String get formattedAvgLateness {
    if (avgLatenessMinutes <= 0) return 'N/A';
    final hours = (avgLatenessMinutes / 60).floor();
    final minutes = (avgLatenessMinutes % 60).round();
    return '${hours}h ${minutes}m';
  }
}

