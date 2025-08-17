import 'package:equatable/equatable.dart';
import 'package:event_reg/features/verification/data/models/participant_info.dart';

import '../../data/models/coupon.dart';
import '../../data/models/verification_response.dart';
// Import attendance models
import '../../../attendance/data/models/attendance_event_model.dart';
import '../../../attendance/data/models/attendance_session.dart';
import '../../../attendance/data/models/attendance_room.dart';

abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

// Original Verification States
class VerificationInitial extends VerificationState {
  const VerificationInitial();

  @override
  String toString() => 'VerificationInitial()';
}

class VerificationLoading extends VerificationState {
  final String badgeNumber;

  const VerificationLoading(this.badgeNumber);

  @override
  List<Object?> get props => [badgeNumber];

  @override
  String toString() => 'VerificationLoading(badgeNumber: $badgeNumber)';
}

class VerificationSuccess extends VerificationState {
  final VerificationResponse response;
  final String badgeNumber;

  const VerificationSuccess({
    required this.response,
    required this.badgeNumber,
  });

  @override
  List<Object?> get props => [response, badgeNumber];

  @override
  String toString() =>
      'VerificationSuccess(badgeNumber: $badgeNumber, response: $response)';
}

class VerificationFailure extends VerificationState {
  final String message;
  final String? code;
  final String badgeNumber;

  const VerificationFailure({
    required this.message,
    required this.badgeNumber,
    this.code,
  });

  @override
  List<Object?> get props => [message, code, badgeNumber];

  @override
  String toString() =>
      'VerificationFailure(badgeNumber: $badgeNumber, message: $message, code: $code)';
}

class CouponsFetched extends VerificationState {
  final List<Coupon> coupons;
  final String participantId;
  final ParticipantInfo participant;

  const CouponsFetched({
    required this.coupons,
    required this.participantId,
    required this.participant,
  });

  @override
  List<Object?> get props => [coupons, participantId, participant];

  @override
  String toString() =>
      'CouponsFetched(participantId: $participantId, participant: ${participant.fullName}, coupons: ${coupons.length})';
}

// Merged Attendance States
class AttendanceError extends VerificationState {
  final String message;
  final String? code;

  const AttendanceError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AttendanceError(message: $message, code: $code)';
}

class EventsLoaded extends VerificationState {
  final List<AttendanceEventModel> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];

  @override
  String toString() => 'EventsLoaded(events: ${events.length})';
}

class EventDetailsLoaded extends VerificationState {
  final AttendanceEventModel event;

  const EventDetailsLoaded(this.event);

  @override
  List<Object?> get props => [event];

  @override
  String toString() => 'EventDetailsLoaded(eventId: ${event.id})';
}

class SessionsLoaded extends VerificationState {
  final List<AttendanceSession> sessions;
  final String eventId;

  const SessionsLoaded({required this.sessions, required this.eventId});

  @override
  List<Object?> get props => [sessions, eventId];

  @override
  String toString() =>
      'SessionsLoaded(eventId: $eventId, sessions: ${sessions.length})';
}

class RoomsLoaded extends VerificationState {
  final List<AttendanceRoom> rooms;
  final String sessionId;

  const RoomsLoaded({required this.rooms, required this.sessionId});

  @override
  List<Object?> get props => [rooms, sessionId];

  @override
  String toString() =>
      'RoomsLoaded(sessionId: $sessionId, rooms: ${rooms.length})';
}

class AttendanceMarkedForLocation extends VerificationState {
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
  List<Object?> get props => [
    badgeNumber,
    eventSessionId,
    sessionLocationId,
    message,
  ];

  @override
  String toString() =>
      'AttendanceMarkedForLocation(badge: $badgeNumber, session: $eventSessionId, location: $sessionLocationId)';
}

// Legacy compatibility state
class AttendanceMarked extends VerificationState {
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

class AttendanceLoading extends VerificationState {}
