class AttendanceEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'upcoming', 'completed'
  final int sessionsCount;

  AttendanceEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.sessionsCount,
  });

  factory AttendanceEventModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEventModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'] ?? 'upcoming',
      sessionsCount: json['sessions_count'] ?? 0,
    );
  }
}