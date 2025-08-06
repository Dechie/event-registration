import 'package:equatable/equatable.dart';

import '../../data/models/verification_response.dart';
// lib/features/verification/presentation/bloc/verification_state.dart


abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
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
  String toString() => 'VerificationSuccess(badgeNumber: $badgeNumber, response: $response)';
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
  String toString() => 'VerificationFailure(badgeNumber: $badgeNumber, message: $message, code: $code)';
}