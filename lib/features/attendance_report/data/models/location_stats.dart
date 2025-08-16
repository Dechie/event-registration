// lib/features/attendance_report/data/models/location_stats.dart
class LocationStats {
  final int locationId;
  final String locationName;
  final int sessionsAttended;
  final int lateCount;

  LocationStats({
    required this.locationId,
    required this.locationName,
    required this.sessionsAttended,
    required this.lateCount,
  });

  factory LocationStats.fromJson(Map<String, dynamic> json) {
    return LocationStats(
      locationId: json['location_id'] ?? 0,
      locationName: json['location_name'] ?? '',
      sessionsAttended: json['sessions_attended'] ?? 0,
      lateCount: json['late_count'] ?? 0,
    );
  }
}

