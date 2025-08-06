// import 'package:equatable/equatable.dart';
// import 'package:event_reg/core/shared/models/participant.dart';

// import 'event.dart';
// import 'session.dart';

// class ParticipantDashboard extends Equatable {
//   final String participantId;
//   final String participantName;
//   final String participantEmail;
//   final List<Event> registeredEvents;
//   final List<Session> attendedSessions;
//   final int totalEvents;
//   final int totalSessions;
//   final int attendedSessionsCount;
//   final double attendanceRate;
//   final DateTime lastActivity;
//   final String? profilePicture;
//   final Map<String, dynamic>? additionalInfo;

//   const ParticipantDashboard({
//     required this.participantId,
//     required this.participantName,
//     required this.participantEmail,
//     required this.registeredEvents,
//     required this.attendedSessions,
//     required this.totalEvents,
//     required this.totalSessions,
//     required this.attendedSessionsCount,
//     required this.attendanceRate,
//     required this.lastActivity,
//     this.profilePicture,
//     this.additionalInfo,
//   });

//   factory ParticipantDashboard.fromJson(Map<String, dynamic> json) {
//     return ParticipantDashboard(
//       participantId: json['participant_id'] ?? '',
//       participantName: json['participant_name'] ?? '',
//       participantEmail: json['participant_email'] ?? '',
//       registeredEvents: (json['registered_events'] as List?)
//               ?.map((e) => Event.fromJson(e))
//               .toList() ??
//           [],
//       attendedSessions: (json['attended_sessions'] as List?)
//               ?.map((e) => Session.fromJson(e))
//               .toList() ??
//           [],
//       totalEvents: json['total_events'] ?? 0,
//       totalSessions: json['total_sessions'] ?? 0,
//       attendedSessionsCount: json['attended_sessions_count'] ?? 0,
//       attendanceRate: (json['attendance_rate'] ?? 0.0).toDouble(),
//       lastActivity: DateTime.parse(json['last_activity'] ?? DateTime.now().toIso8601String()),
//       profilePicture: json['profile_picture'],
//       additionalInfo: json['additional_info'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'participant_id': participantId,
//       'participant_name': participantName,
//       'participant_email': participantEmail,
//       'registered_events': registeredEvents.map((e) => e.toJson()).toList(),
//       'attended_sessions': attendedSessions.map((e) => e.toJson()).toList(),
//       'total_events': totalEvents,
//       'total_sessions': totalSessions,
//       'attended_sessions_count': attendedSessionsCount,
//       'attendance_rate': attendanceRate,
//       'last_activity': lastActivity.toIso8601String(),
//       'profile_picture': profilePicture,
//       'additional_info': additionalInfo,
//     };
//   }

//   @override
//   List<Object?> get props => [
//         participantId,
//         participantName,
//         participantEmail,
//         registeredEvents,
//         attendedSessions,
//         totalEvents,
//         totalSessions,
//         attendedSessionsCount,
//         attendanceRate,
//         lastActivity,
//         profilePicture,
//         additionalInfo,
//       ];
// }
