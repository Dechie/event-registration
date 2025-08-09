class AttendanceSession {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'active', 'upcoming', 'completed'
  final int roomsCount;
  final bool isActive;

  AttendanceSession({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.roomsCount,
    required this.isActive,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'].toString(),
      eventId: json['event_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status'] ?? 'upcoming',
      roomsCount: json['rooms_count'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
}