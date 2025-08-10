import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

// Load detailed event info with sessions and locations
class LoadEventDetails extends AttendanceEvent {
  final String eventId;

  const LoadEventDetails(this.eventId);

  @override
  List<Object?> get props => [eventId];

  @override
  String toString() => 'LoadEventDetails(eventId: $eventId)';
}

class LoadEventsForAttendance extends AttendanceEvent {
  const LoadEventsForAttendance();

  @override
  String toString() => 'LoadEventsForAttendance()';
}

class LoadRoomsForSession extends AttendanceEvent {
  final String sessionId;

  const LoadRoomsForSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];

  @override
  String toString() => 'LoadRoomsForSession(sessionId: $sessionId)';
}

class LoadSessionsForEvent extends AttendanceEvent {
  final String eventId;

  const LoadSessionsForEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];

  @override
  String toString() => 'LoadSessionsForEvent(eventId: $eventId)';
}

// Mark attendance for a specific location
class MarkAttendanceForLocation extends AttendanceEvent {
  final String badgeNumber;
  final String eventSessionId;
  final String sessionLocationId; // Updated to use location ID

  const MarkAttendanceForLocation({
    required this.badgeNumber,
    required this.eventSessionId,
    required this.sessionLocationId,
  });

  @override
  List<Object?> get props => [badgeNumber, eventSessionId, sessionLocationId];
}
