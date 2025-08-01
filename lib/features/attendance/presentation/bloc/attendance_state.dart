import 'package:equatable/equatable.dart';
import 'package:event_reg/features/dashboard/data/models/session.dart';
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}
class AttendanceErrorState extends AttendanceState {
  final String message;
  const AttendanceErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

class AttendanceInitialState extends AttendanceState {
  @override
  List<Object?> get props => [];
}

class AttendanceLoadingState extends AttendanceState {
  @override
  List<Object?> get props => [];
}



class AvailableSessionsLoadedState extends AttendanceState {
  final List<Session> sessions;
  const AvailableSessionsLoadedState({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class SessionsRegistrationErrorState extends AttendanceState {
  @override
  List<Object?> get props => [];
}
