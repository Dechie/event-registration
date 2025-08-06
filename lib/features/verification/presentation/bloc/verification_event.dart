import 'package:equatable/equatable.dart';

// lib/features/verification/presentation/bloc/verification_event.dart


abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyBadgeRequested extends VerificationEvent {
  final String badgeNumber;

  const VerifyBadgeRequested(this.badgeNumber);

  @override
  List<Object?> get props => [badgeNumber];

  @override
  String toString() => 'VerifyBadgeRequested(badgeNumber: $badgeNumber)';
}

class ResetVerificationState extends VerificationEvent {
  const ResetVerificationState();

  @override
  String toString() => 'ResetVerificationState()';
}