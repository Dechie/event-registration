// lib/features/verification/presentation/bloc/verification_event.dart

import 'package:equatable/equatable.dart';

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

  const VerifyBadgeRequested(
    this.badgeNumber, {
    this.verificationType = 'security',
    this.eventSessionId,
    this.couponId,
  });

  @override
  List<Object?> get props => [badgeNumber, verificationType, eventSessionId, couponId];

  @override
  String toString() => 'VerifyBadgeRequested(badgeNumber: $badgeNumber, type: $verificationType, eventSessionId: $eventSessionId, couponId: $couponId)';
}

class ResetVerificationState extends VerificationEvent {
  const ResetVerificationState();

  @override
  String toString() => 'ResetVerificationState()';
}