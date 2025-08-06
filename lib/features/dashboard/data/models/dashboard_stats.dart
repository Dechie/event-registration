// import 'package:equatable/equatable.dart';

// class DashboardStats extends Equatable {
//   final int totalParticipants;
//   final int totalEvents;
//   final int totalSessions;
//   final int activeEvents;
//   final int completedEvents;
//   final double averageAttendance;
//   final int checkedInToday;
//   final int checkedOutToday;
//   final Map<String, int> attendanceByEvent;
//   final Map<String, int> attendanceBySession;
//   final List<Map<String, dynamic>> recentActivity;

//   const DashboardStats({
//     required this.totalParticipants,
//     required this.totalEvents,
//     required this.totalSessions,
//     required this.activeEvents,
//     required this.completedEvents,
//     required this.averageAttendance,
//     required this.checkedInToday,
//     required this.checkedOutToday,
//     required this.attendanceByEvent,
//     required this.attendanceBySession,
//     required this.recentActivity,
//   });

//   factory DashboardStats.fromJson(Map<String, dynamic> json) {
//     return DashboardStats(
//       totalParticipants: json['total_participants'] ?? 0,
//       totalEvents: json['total_events'] ?? 0,
//       totalSessions: json['total_sessions'] ?? 0,
//       activeEvents: json['active_events'] ?? 0,
//       completedEvents: json['completed_events'] ?? 0,
//       averageAttendance: (json['average_attendance'] ?? 0.0).toDouble(),
//       checkedInToday: json['checked_in_today'] ?? 0,
//       checkedOutToday: json['checked_out_today'] ?? 0,
//       attendanceByEvent: Map<String, int>.from(json['attendance_by_event'] ?? {}),
//       attendanceBySession: Map<String, int>.from(json['attendance_by_session'] ?? {}),
//       recentActivity: List<Map<String, dynamic>>.from(json['recent_activity'] ?? []),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'total_participants': totalParticipants,
//       'total_events': totalEvents,
//       'total_sessions': totalSessions,
//       'active_events': activeEvents,
//       'completed_events': completedEvents,
//       'average_attendance': averageAttendance,
//       'checked_in_today': checkedInToday,
//       'checked_out_today': checkedOutToday,
//       'attendance_by_event': attendanceByEvent,
//       'attendance_by_session': attendanceBySession,
//       'recent_activity': recentActivity,
//     };
//   }

//   @override
//   List<Object?> get props => [
//         totalParticipants,
//         totalEvents,
//         totalSessions,
//         activeEvents,
//         completedEvents,
//         averageAttendance,
//         checkedInToday,
//         checkedOutToday,
//         attendanceByEvent,
//         attendanceBySession,
//         recentActivity,
//       ];
// }
