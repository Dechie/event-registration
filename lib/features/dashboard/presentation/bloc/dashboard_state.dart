
// import 'package:event_reg/core/shared/models/participant.dart';

// import '../../data/models/dashboard_stats.dart';
// import '../../data/models/participant_dashboard.dart';
// import '../../data/models/session.dart';

// abstract class DashboardState {}

// class DashboardInitial extends DashboardState {}

// class DashboardLoading extends DashboardState {}

// class DashboardError extends DashboardState {
//   final String message;

//   DashboardError({required this.message});
// }

// // Admin Dashboard States
// class DashboardStatsLoaded extends DashboardState {
//   final DashboardStats stats;

//   DashboardStatsLoaded({required this.stats});
// }

// class ParticipantsLoaded extends DashboardState {
//   final List<Participant> participants;
//   final String? searchQuery;
//   final String? sessionFilter;
//   final String? statusFilter;

//   ParticipantsLoaded({
//     required this.participants,
//     this.searchQuery,
//     this.sessionFilter,
//     this.statusFilter,
//   });
// }

// class ParticipantCheckedIn extends DashboardState {
//   final String participantId;
//   final bool success;

//   ParticipantCheckedIn({required this.participantId, required this.success});
// }

// class SessionsLoaded extends DashboardState {
//   final List<Session> sessions;

//   SessionsLoaded({required this.sessions});
// }

// class AttendanceAnalyticsLoaded extends DashboardState {
//   final Map<String, dynamic> analytics;

//   AttendanceAnalyticsLoaded({required this.analytics});
// }

// // Participant Dashboard States
// class ParticipantDashboardLoaded extends DashboardState {
//   final ParticipantDashboard dashboard;

//   ParticipantDashboardLoaded({required this.dashboard});
// }

// class ParticipantInfoUpdated extends DashboardState {
//   final bool success;

//   ParticipantInfoUpdated({required this.success});
// }

// class ConfirmationPdfReady extends DashboardState {
//   final String downloadUrl;

//   ConfirmationPdfReady({required this.downloadUrl});
// }

// class DashboardCacheCleared extends DashboardState {}
