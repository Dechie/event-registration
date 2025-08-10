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
    // Handle different possible field names from the API
    final sessionIdField = json['session_id'] ?? json['sessionId'] ?? '';
    final capacityField = json['capacity'] ?? json['max_capacity'] ?? json['maxCapacity'] ?? 0;
    final attendanceCountField = json['attendance_count'] ?? json['attendanceCount'] ?? json['current_attendance'] ?? json['currentAttendance'] ?? 0;
    
    return AttendanceRoom(
      id: json['id'].toString(),
      sessionId: sessionIdField.toString(),
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'],
      capacity: capacityField is int ? capacityField : 0,
      attendanceCount: attendanceCountField is int ? attendanceCountField : 0,
      location: json['location'] ?? json['venue'] ?? json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'attendance_count': attendanceCount,
      'location': location,
    };
  }

  @override
  String toString() {
    return 'AttendanceRoom(id: $id, name: $name, sessionId: $sessionId, capacity: $capacity, attendanceCount: $attendanceCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceRoom && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
