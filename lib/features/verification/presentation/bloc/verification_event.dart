// // // lib/features/verification/presentation/bloc/verification_event.dart

// // import 'package:equatable/equatable.dart';

// // import '../../data/models/participant_info.dart';

// // class FetchParticipantCoupons extends VerificationEvent {
// //   final String participantId;
// //   final ParticipantInfo participant;

// //   const FetchParticipantCoupons(this.participantId, this.participant);

// //   @override
// //   List<Object?> get props => [participantId, participant];

// //   @override
// //   String toString() =>
// //       'FetchParticipantCoupons(participantId: $participantId, participant: ${participant.fullName})';
// // }

// // class ResetVerificationState extends VerificationEvent {
// //   const ResetVerificationState();

// //   @override
// //   String toString() => 'ResetVerificationState()';
// // }

// // abstract class VerificationEvent extends Equatable {
// //   const VerificationEvent();

// //   @override
// //   List<Object?> get props => [];
// // }

// // class VerifyBadgeRequested extends VerificationEvent {
// //   final String badgeNumber;
// //   final String verificationType;
// //   final String? eventSessionId;
// //   final String? couponId;
// //   final String? eventId; // Added for attendance tracking
// //   final String? roomId; // Added for attendance tracking
// //   final String? sessionLocationId;

// //   const VerifyBadgeRequested({
// //     required this.badgeNumber,
// //     required this.verificationType,
// //     this.sessionLocationId,
// //     this.eventSessionId,
// //     this.couponId,
// //     this.eventId,
// //     this.roomId,
// //   });

// //   @override
// //   List<Object?> get props => [
// //     badgeNumber,
// //     verificationType,
// //     eventSessionId,
// //     couponId,
// //     eventId,
// //     roomId,
// //   ];

// //   @override
// //   String toString() =>
// //       'VerifyBadgeRequested(badgeNumber: $badgeNumber, verificationType: $verificationType, eventSessionId: $eventSessionId, couponId: $couponId, eventId: $eventId, roomId: $roomId)';
// // }

// // lib/features/verification/presentation/bloc/verification_event.dart

// import 'package:equatable/equatable.dart';

// import '../../data/models/participant_info.dart';

// abstract class VerificationEvent extends Equatable {
//   const VerificationEvent();

//   @override
//   List<Object?> get props => [];
// }

// // Original Verification Events
// class VerifyBadgeRequested extends VerificationEvent {
//   final String badgeNumber;
//   final String verificationType;
//   final String? eventSessionId;
//   final String? couponId;
//   final String? eventId; // Added for attendance tracking
//   final String? roomId; // Added for attendance tracking
//   final String? sessionLocationId;

//   const VerifyBadgeRequested({
//     required this.badgeNumber,
//     required this.verificationType,
//     this.sessionLocationId,
//     this.eventSessionId,
//     this.couponId,
//     this.eventId,
//     this.roomId,
//   });

//   @override
//   List<Object?> get props => [
//     badgeNumber,
//     verificationType,
//     eventSessionId,
//     couponId,
//     eventId,
//     roomId,
//   ];

//   @override
//   String toString() =>
//       'VerifyBadgeRequested(badgeNumber: $badgeNumber, verificationType: $verificationType, eventSessionId: $eventSessionId, couponId: $couponId, eventId: $eventId, roomId: $roomId)';
// }

// class FetchParticipantCoupons extends VerificationEvent {
//   final String participantId;
//   final ParticipantInfo participant;

//   const FetchParticipantCoupons(this.participantId, this.participant);

//   @override
//   List<Object?> get props => [participantId, participant];

//   @override
//   String toString() =>
//       'FetchParticipantCoupons(participantId: $participantId, participant: ${participant.fullName})';
// }

// class ResetVerificationState extends VerificationEvent {
//   const ResetVerificationState();

//   @override
//   String toString() => 'ResetVerificationState()';
// }

// // Merged Attendance Events
// class LoadEventsForAttendance extends VerificationEvent {
//   const LoadEventsForAttendance();

//   @override
//   String toString() => 'LoadEventsForAttendance()';
// }

// class LoadEventDetails extends VerificationEvent {
//   final String eventId;

//   const LoadEventDetails(this.eventId);

//   @override
//   List<Object?> get props => [eventId];

//   @override
//   String toString() => 'LoadEventDetails(eventId: $eventId)';
// }

// class LoadSessionsForEvent extends VerificationEvent {
//   final String eventId;

//   const LoadSessionsForEvent(this.eventId);

//   @override
//   List<Object?> get props => [eventId];

//   @override
//   String toString() => 'LoadSessionsForEvent(eventId: $eventId)';
// }

// class LoadRoomsForSession extends VerificationEvent {
//   final String sessionId;

//   const LoadRoomsForSession(this.sessionId);

//   @override
//   List<Object?> get props => [sessionId];

//   @override
//   String toString() => 'LoadRoomsForSession(sessionId: $sessionId)';
// }

// class MarkAttendanceForLocation extends VerificationEvent {
//   final String badgeNumber;
//   final String eventSessionId;
//   final String sessionLocationId;

//   const MarkAttendanceForLocation({
//     required this.badgeNumber,
//     required this.eventSessionId,
//     required this.sessionLocationId,
//   });

//   @override
//   List<Object?> get props => [badgeNumber, eventSessionId, sessionLocationId];

//   @override
//   String toString() =>
//       'MarkAttendanceForLocation(badge: $badgeNumber, session: $eventSessionId, location: $sessionLocationId)';
// }
// lib/features/verification/presentation/bloc/verification_event.dart

import 'package:equatable/equatable.dart';

import '../../data/models/participant_info.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

// Original Verification Events
class VerifyBadgeRequested extends VerificationEvent {
  final String badgeNumber;
  final String verificationType;
  final String? eventSessionId;
  final String? couponId;
  final String? eventId; // Added for attendance tracking
  final String? roomId; // Added for attendance tracking
  final String? sessionLocationId;

  const VerifyBadgeRequested({
    required this.badgeNumber,
    required this.verificationType,
    this.sessionLocationId,
    this.eventSessionId,
    this.couponId,
    this.eventId,
    this.roomId,
  });

  @override
  List<Object?> get props => [
    badgeNumber,
    verificationType,
    eventSessionId,
    couponId,
    eventId,
    roomId,
  ];

  @override
  String toString() =>
      'VerifyBadgeRequested(badgeNumber: $badgeNumber, verificationType: $verificationType, eventSessionId: $eventSessionId, couponId: $couponId, eventId: $eventId, roomId: $roomId)';
}

class FetchParticipantCoupons extends VerificationEvent {
  final String participantId;
  final ParticipantInfo participant;

  const FetchParticipantCoupons(this.participantId, this.participant);

  @override
  List<Object?> get props => [participantId, participant];

  @override
  String toString() =>
      'FetchParticipantCoupons(participantId: $participantId, participant: ${participant.fullName})';
}

class ResetVerificationState extends VerificationEvent {
  const ResetVerificationState();

  @override
  String toString() => 'ResetVerificationState()';
}

// Merged Attendance Events
class LoadEventsForAttendance extends VerificationEvent {
  const LoadEventsForAttendance();

  @override
  String toString() => 'LoadEventsForAttendance()';
}

class LoadEventDetails extends VerificationEvent {
  final String eventId;

  const LoadEventDetails(this.eventId);

  @override
  List<Object?> get props => [eventId];

  @override
  String toString() => 'LoadEventDetails(eventId: $eventId)';
}

class LoadSessionsForEvent extends VerificationEvent {
  final String eventId;

  const LoadSessionsForEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];

  @override
  String toString() => 'LoadSessionsForEvent(eventId: $eventId)';
}

class LoadRoomsForSession extends VerificationEvent {
  final String sessionId;

  const LoadRoomsForSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];

  @override
  String toString() => 'LoadRoomsForSession(sessionId: $sessionId)';
}

class MarkAttendanceForLocation extends VerificationEvent {
  final String badgeNumber;
  final String eventSessionId;
  final String sessionLocationId;

  const MarkAttendanceForLocation({
    required this.badgeNumber,
    required this.eventSessionId,
    required this.sessionLocationId,
  });

  @override
  List<Object?> get props => [badgeNumber, eventSessionId, sessionLocationId];

  @override
  String toString() =>
      'MarkAttendanceForLocation(badge: $badgeNumber, session: $eventSessionId, location: $sessionLocationId)';
}