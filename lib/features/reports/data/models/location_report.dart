// lib/features/reports/data/models/location_report.dart
import 'attendance_stats.dart';

class LocationReport {
  final int locationId;
  final String locationName;
  final int capacity;
  final int allocated;
  final AttendanceStats stats;

  LocationReport({
    required this.locationId,
    required this.locationName,
    required this.capacity,
    required this.allocated,
    required this.stats,
  });

  factory LocationReport.fromJson(Map<String, dynamic> json) {
    return LocationReport(
      locationId: json['location_id'] ?? 0,
      locationName: json['location_name'] ?? '',
      capacity: json['capacity'] ?? 0,
      allocated: json['allocated'] ?? 0,
      stats: AttendanceStats.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'location_name': locationName,
      'capacity': capacity,
      'allocated': allocated,
      'stats': stats.toJson(),
    };
  }

  double get utilizationRate => allocated > 0 ? (stats.totalAttendance / allocated) * 100 : 0.0;
  double get capacityRate => capacity > 0 ? (allocated / capacity) * 100 : 0.0;

  @override
  String toString() {
    return 'LocationReport(locationId: $locationId, locationName: $locationName, capacity: $capacity, allocated: $allocated)';
  }
}

