// lib/features/verification/presentation/bloc/verification_event.dart

import 'package:equatable/equatable.dart';

import '../../data/models/participant_info.dart';

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

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

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
