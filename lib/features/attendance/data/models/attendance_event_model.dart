import 'attendance_session.dart';

class AttendanceEventModel {
  final String id;
  final String title;
  final String? description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String? banner;
  final String organizationId;
  final List<AttendanceSession> sessions;

  AttendanceEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.banner,
    required this.organizationId,
    required this.sessions,
  });
  factory AttendanceEventModel.fromJson(Map<String, dynamic> json) {
    // Handle different possible field names from the API
    final startTimeField =
        json['start_time'] ??
        json['startTime'] ??
        json['start_date'] ??
        json['startDate'];
    final endTimeField =
        json['end_time'] ??
        json['endTime'] ??
        json['end_date'] ??
        json['endDate'];
    final isActiveField = json['is_active'] ?? json['isActive'] ?? false;

    // Parse nested sessions
    List<AttendanceSession> sessionsList = [];
    if (json['sessions'] != null && json['sessions'] is List) {
      sessionsList = (json['sessions'] as List)
          .map((sessionJson) => AttendanceSession.fromJson(sessionJson))
          .toList();
    }

    if (sessionsList.isEmpty) {
      sessionsList = _getMockSessions("1");
    }

    return AttendanceEventModel(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'],
      location: json['location'] ?? '',
      startTime: startTimeField is String
          ? DateTime.parse(startTimeField)
          : startTimeField is DateTime
          ? startTimeField
          : DateTime.now(),
      endTime: endTimeField is String
          ? DateTime.parse(endTimeField)
          : endTimeField is DateTime
          ? endTimeField
          : DateTime.now().add(const Duration(days: 1)),
      isActive: isActiveField is bool ? isActiveField : (isActiveField == 1),
      banner: json['banner'],
      organizationId: json['organization_id']?.toString() ?? '',
      sessions: sessionsList,
    );
  }

  @override
  int get hashCode => id.hashCode;

  int get sessionsCount => sessions.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AttendanceEventModel && other.id == id;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
      'banner': banner,
      'organization_id': organizationId,
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AttendanceEventModel(id: $id, title: $title, location: $location, isActive: $isActive, sessionsCount: ${sessions.length})';
  }

  static List<AttendanceSession> _getMockSessions(String eventId) {
    return [
      AttendanceSession(
        id: '1',
        eventId: eventId,
        title: 'Opening Ceremony',
        description: 'Welcome and introduction to the event',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        isActive: true,
        roomsCount: 3,
      ),
      AttendanceSession(
        id: '2',
        eventId: eventId,
        title: 'Technical Workshop',
        description: 'Hands-on technical training session',
        startTime: DateTime.now().add(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        isActive: true,
        roomsCount: 4,
      ),
      AttendanceSession(
        id: '3',
        eventId: eventId,
        title: 'Panel Discussion',
        description: 'Industry experts discussing current trends',
        startTime: DateTime.now().add(const Duration(hours: 6)),
        endTime: DateTime.now().add(const Duration(hours: 7)),
        isActive: false,
        roomsCount: 2,
      ),
    ];
  }
}
