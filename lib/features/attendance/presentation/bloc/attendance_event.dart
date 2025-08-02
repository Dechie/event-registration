import 'package:equatable/equatable.dart';
import 'package:event_reg/features/dashboard/data/models/session.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
} 

class LoadAvailableSessionsEvent extends AttendanceEvent {
  const LoadAvailableSessionsEvent();

  @override
  List<Object?> get props => [];
}

class RegisterForSessionsEvent extends AttendanceEvent {
  final List<Session> selectedSessions;
  final Map<String, dynamic>? profileData;

  const RegisterForSessionsEvent({
    required this.selectedSessions,
    this.profileData,
  });

  @override
  List<Object?> get props => [selectedSessions, profileData];
}

class UpdateSessionSelectionEvent extends AttendanceEvent {
  final List<Session> selectedSessions;

  const UpdateSessionSelectionEvent({
    required this.selectedSessions,
  });

  @override
  List<Object?> get props => [selectedSessions];
}

class GetParticipantSessionsEvent extends AttendanceEvent {
  final String participantId;

  const GetParticipantSessionsEvent({
    required this.participantId,
  });

  @override
  List<Object?> get props => [participantId];
}