import 'package:equatable/equatable.dart';
import 'package:event_reg/features/attendance/data/models/attendance_event_model.dart';

import '../../data/models/attendance_room.dart';
import '../../data/models/attendance_session.dart';

class AttendanceError extends AttendanceState {
  final String message;
  final String? code;

  const AttendanceError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AttendanceError(message: $message, code: $code)';
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceMarked extends AttendanceState {
  final String participantId;
  final String sessionId;
  final String roomId;
  final String message;

  const AttendanceMarked({
    required this.participantId,
    required this.sessionId,
    required this.roomId,
    required this.message,
  });

  @override
  List<Object?> get props => [participantId, sessionId, roomId, message];

  @override
  String toString() =>
      'AttendanceMarked(participantId: $participantId, sessionId: $sessionId, roomId: $roomId)';
}

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class EventDetailsLoaded extends AttendanceState {
  final AttendanceEventModel event;

  const EventDetailsLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventsLoaded extends AttendanceState {
  final List<AttendanceEventModel> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];

  @override
  String toString() => 'EventsLoaded(events: ${events.length})';
}
class AttendanceMarkedForLocation extends AttendanceState {
  final String badgeNumber;
  final String eventSessionId;
  final String sessionLocationId;
  final String message;

  const AttendanceMarkedForLocation({
    required this.badgeNumber,
    required this.eventSessionId,
    required this.sessionLocationId,
    required this.message,
  });

  @override
  List<Object?> get props => [badgeNumber, eventSessionId, sessionLocationId, message];

  @override
  String toString() =>
      'AttendanceMarkedForLocation(badge: $badgeNumber, session: $eventSessionId, location: $sessionLocationId)';
}
class RoomsLoaded extends AttendanceState {
  final List<AttendanceRoom> rooms;
  final String sessionId;

  const RoomsLoaded({required this.rooms, required this.sessionId});

  @override
  List<Object?> get props => [rooms, sessionId];

  @override
  String toString() =>
      'RoomsLoaded(sessionId: $sessionId, rooms: ${rooms.length})';
}

class SessionsLoaded extends AttendanceState {
  final List<AttendanceSession> sessions;
  final String eventId;

  const SessionsLoaded({required this.sessions, required this.eventId});

  @override
  List<Object?> get props => [sessions, eventId];

  @override
  String toString() =>
      'SessionsLoaded(eventId: $eventId, sessions: ${sessions.length})';
}
