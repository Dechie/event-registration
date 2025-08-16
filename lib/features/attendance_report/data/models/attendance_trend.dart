// lib/features/attendance_report/data/models/attendance_trend.dart
class AttendanceTrend {
  final String date;
  final int count;
  final int present;
  final int late;
  final int absent;

  AttendanceTrend({
    required this.date,
    required this.count,
    required this.present,
    required this.late,
    required this.absent,
  });

  factory AttendanceTrend.fromJson(Map<String, dynamic> json) {
    return AttendanceTrend(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      present: json['present'] ?? 0,
      late: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }

  DateTime get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (e) {
      return date;
    }
  }
}

