import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventsForAttendance extends AttendanceEvent {
  const LoadEventsForAttendance();

  @override
  String toString() => 'LoadEventsForAttendance()';
}

class LoadSessionsForEvent extends AttendanceEvent {
  final String eventId;

  const LoadSessionsForEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];

  @override
  String toString() => 'LoadSessionsForEvent(eventId: $eventId)';
}

class LoadRoomsForSession extends AttendanceEvent {
  final String sessionId;

  const LoadRoomsForSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];

  @override
  String toString() => 'LoadRoomsForSession(sessionId: $sessionId)';
}

class MarkAttendance extends AttendanceEvent {
  final String participantId;
  final String sessionId;
  final String roomId;

  const MarkAttendance({
    required this.participantId,
    required this.sessionId,
    required this.roomId,
  });

  @override
  List<Object?> get props => [participantId, sessionId, roomId];

  @override
  String toString() => 'MarkAttendance(participantId: $participantId, sessionId: $sessionId, roomId: $roomId)';
}
