class AttendanceSession {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final int roomsCount;

  AttendanceSession({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.roomsCount,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    // Handle different possible field names from the API
    final startTimeField = json['start_time'] ?? json['startTime'] ?? json['start_date'] ?? json['startDate'];
    final endTimeField = json['end_time'] ?? json['endTime'] ?? json['end_date'] ?? json['endDate'];
    final eventIdField = json['event_id'] ?? json['eventId'] ?? '';
    final isActiveField = json['is_active'] ?? json['isActive'] ?? true;
    final roomsCountField = json['rooms_count'] ?? json['roomsCount'] ?? json['rooms']?.length ?? 0;
    
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
              : DateTime.now().add(const Duration(hours: 1)),
      isActive: isActiveField is bool ? isActiveField : (isActiveField == 1),
      roomsCount: roomsCountField is int ? roomsCountField : 0,
    );
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
      'rooms_count': roomsCount,
    };
  }

  @override
  String toString() {
    return 'AttendanceSession(id: $id, title: $title, eventId: $eventId, isActive: $isActive, roomsCount: $roomsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}