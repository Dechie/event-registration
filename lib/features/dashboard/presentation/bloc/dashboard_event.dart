// lib/features/dashboard/presentation/bloc/dashboard_event.dart
abstract class DashboardEvent {}

// Admin Dashboard Events
class LoadDashboardStatsEvent extends DashboardEvent {}

class LoadParticipantsEvent extends DashboardEvent {
  final String? searchQuery;
  final String? sessionFilter;
  final String? statusFilter;

  LoadParticipantsEvent({
    this.searchQuery,
    this.sessionFilter,
    this.statusFilter,
  });
}

class CheckInParticipantEvent extends DashboardEvent {
  final String participantId;

  CheckInParticipantEvent({required this.participantId});
}

class CheckOutParticipantEvent extends DashboardEvent {
  final String participantId;

  CheckOutParticipantEvent({required this.participantId});
}

class LoadSessionsEvent extends DashboardEvent {}

class LoadAttendanceAnalyticsEvent extends DashboardEvent {}

// Participant Dashboard Events
class LoadParticipantDashboardEvent extends DashboardEvent {
  final String email;

  LoadParticipantDashboardEvent({required this.email});
}

class UpdateParticipantInfoEvent extends DashboardEvent {
  final String participantId;
  final Map<String, dynamic> updateData;

  UpdateParticipantInfoEvent({
    required this.participantId,
    required this.updateData,
  });
}

class DownloadConfirmationPdfEvent extends DashboardEvent {
  final String participantId;

  DownloadConfirmationPdfEvent({required this.participantId});
}

class ClearDashboardCacheEvent extends DashboardEvent {}

class RefreshDashboardEvent extends DashboardEvent {}
