import 'package:equatable/equatable.dart';
import 'package:event_reg/features/verification/data/models/participant_info.dart';

import '../../data/models/coupon.dart';
import '../../data/models/verification_response.dart';

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

// lib/features/verification/presentation/bloc/verification_state.dart

abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
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
