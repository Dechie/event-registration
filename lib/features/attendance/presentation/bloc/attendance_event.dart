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

class UpdateSessionSelectionEvent extends AttendanceEvent {
  final List<Session> selectedSessions;
  final Map<String, dynamic> profileData;

  const UpdateSessionSelectionEvent({
    required this.selectedSessions,
    required this.profileData,
  });

  @override
  List<Object?> get props => [];
}
