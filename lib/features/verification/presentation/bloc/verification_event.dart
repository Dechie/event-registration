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

  const VerifyBadgeRequested(
    this.badgeNumber, {
    this.verificationType = 'security',
  });

  @override
  List<Object?> get props => [badgeNumber, verificationType];

  @override
  String toString() => 'VerifyBadgeRequested(badgeNumber: $badgeNumber, type: $verificationType)';
}

class ResetVerificationState extends VerificationEvent {
  const ResetVerificationState();

  @override
  String toString() => 'ResetVerificationState()';
}