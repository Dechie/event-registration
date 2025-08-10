class AttendanceLocation {
  final String id;
  final String name;
  final String? placeId;
  final String type;
  final int capacity;
  final int attendanceCount; // This will be fetched separately if needed

  AttendanceLocation({
    required this.id,
    required this.name,
    this.placeId,
    required this.type,
    required this.capacity,
    this.attendanceCount = 0,
  });

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) {
    return AttendanceLocation(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      placeId: json['place_id']?.toString(),
      type: json['type'] ?? 'physical',
      capacity: json['capacity'] ?? 0,
      attendanceCount: json['attendance_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'place_id': placeId,
      'type': type,
      'capacity': capacity,
      'attendance_count': attendanceCount,
    };
  }

  @override
  String toString() {
    return 'AttendanceLocation(id: $id, name: $name, type: $type, capacity: $capacity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendanceLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}