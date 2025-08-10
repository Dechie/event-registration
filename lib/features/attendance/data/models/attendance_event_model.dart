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
  final int sessionsCount;

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
    required this.sessionsCount,
  });

  factory AttendanceEventModel.fromJson(Map<String, dynamic> json) {
    // Handle different possible field names from the API
    final startTimeField = json['start_time'] ?? json['startTime'] ?? json['start_date'] ?? json['startDate'];
    final endTimeField = json['end_time'] ?? json['endTime'] ?? json['end_date'] ?? json['endDate'];
    final isActiveField = json['is_active'] ?? json['isActive'] ?? false;
    final sessionsCountField = json['sessions_count'] ?? json['sessionsCount'] ?? json['sessions']?.length ?? 0;
    
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
      sessionsCount: sessionsCountField is int ? sessionsCountField : 0,
    );
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
      'sessions_count': sessionsCount,
    };
  }

  @override
  String toString() {
    return 'AttendanceEventModel(id: $id, title: $title, location: $location, isActive: $isActive, sessionsCount: $sessionsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceEventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}