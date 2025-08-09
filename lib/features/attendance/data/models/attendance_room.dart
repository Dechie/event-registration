class AttendanceRoom {
  final String id;
  final String sessionId;
  final String name;
  final String? description;
  final int capacity;
  final int attendanceCount;
  final String? location;

  AttendanceRoom({
    required this.id,
    required this.sessionId,
    required this.name,
    this.description,
    required this.capacity,
    required this.attendanceCount,
    this.location,
  });

  factory AttendanceRoom.fromJson(Map<String, dynamic> json) {
    return AttendanceRoom(
      id: json['id'].toString(),
      sessionId: json['session_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      capacity: json['capacity'] ?? 0,
      attendanceCount: json['attendance_count'] ?? 0,
      location: json['location'],
    );
  }
}
