// lib/features/attendance/data/models/attendance_session.dart
import 'attendance_location.dart';

class AttendanceSession {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String status;
  final List<AttendanceLocation> locations;

  AttendanceSession({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.status,
    required this.locations,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    // Handle different possible field names from the API
    final startTimeField = json['start_time'] ?? json['startTime'];
    final endTimeField = json['end_time'] ?? json['endTime'];
    final eventIdField = json['event_id'] ?? json['eventId'] ?? '';
    final isActiveField = json['is_active'] ?? json['isActive'] ?? true;

    // Parse locations array
    List<AttendanceLocation> locationsList = [];
    if (json['locations'] != null && json['locations'] is List) {
      locationsList = (json['locations'] as List)
          .map((locationJson) => AttendanceLocation.fromJson(locationJson))
          .toList();
    }

    return AttendanceSession(
      id: json['id'].toString(),
      eventId: eventIdField.toString(),
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'],
      startTime: startTimeField is String 
          ? DateTime.parse(startTimeField)
          : startTimeField is DateTime 
          ? startTimeField 
          : DateTime.now(),
      endTime: endTimeField is String 
          ? DateTime.parse(endTimeField)
          : endTimeField is DateTime 
          ? endTimeField 
          : DateTime.now().add(Duration(hours: 1)),
      isActive: isActiveField is bool ? isActiveField : (isActiveField == 1),
      status: json['status'] ?? 'Scheduled',
      locations: locationsList,
    );
  }

  int get locationsCount => locations.length;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceSession && other.id == id;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
      'status': status,
      'locations': locations.map((location) => location.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AttendanceSession(id: $id, title: $title, eventId: $eventId, isActive: $isActive, locationsCount: ${locations.length})';
  }
}