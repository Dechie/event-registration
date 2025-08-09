import 'package:equatable/equatable.dart';
import 'package:event_reg/features/attendance/data/models/attendance_event_model.dart';
import '../../data/models/attendance_room.dart';
import '../../data/models/attendance_session.dart';
import '../pages/event_list_page.dart';
import '../pages/session_list_page.dart';
import '../pages/room_list_page.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();

  @override
  String toString() => 'AttendanceInitial()';
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();

  @override
  String toString() => 'AttendanceLoading()';
}

class AttendanceError extends AttendanceState {
  final String message;
  final String? code;

  const AttendanceError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AttendanceError(message: $message, code: $code)';
}

class EventsLoaded extends AttendanceState {
  final List<AttendanceEventModel> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];

  @override
  String toString() => 'EventsLoaded(events: ${events.length})';
}

class SessionsLoaded extends AttendanceState {
  final List<AttendanceSession> sessions;
  final String eventId;

  const SessionsLoaded({
    required this.sessions,
    required this.eventId,
  });

  @override
  List<Object?> get props => [sessions, eventId];

  @override
  String toString() => 'SessionsLoaded(eventId: $eventId, sessions: ${sessions.length})';
}

class RoomsLoaded extends AttendanceState {
  final List<AttendanceRoom> rooms;
  final String sessionId;

  const RoomsLoaded({
    required this.rooms,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [rooms, sessionId];

  @override
  String toString() => 'RoomsLoaded(sessionId: $sessionId, rooms: ${rooms.length})';
}

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
  String toString() => 'AttendanceMarked(participantId: $participantId, sessionId: $sessionId, roomId: $roomId)';
} 