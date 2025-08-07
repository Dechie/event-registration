// lib/features/verification/presentation/bloc/verification_bloc.dart

import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/verification_repository.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository repository;

  VerificationBloc({
    required this.repository,
  }) : super(const VerificationInitial()) {
    on<VerifyBadgeRequested>(_onVerifyBadgeRequested);
    on<ResetVerificationState>(_onResetVerificationState);
  }

  Future<void> _onVerifyBadgeRequested(
    VerifyBadgeRequested event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      debugPrint('🔍 Starting verification for badge: ${event.badgeNumber} (type: ${event.verificationType})');
      
      // Validate badge number
      if (event.badgeNumber.trim().isEmpty) {
        emit(VerificationFailure(
          message: 'Badge number cannot be empty',
          badgeNumber: event.badgeNumber,
          code: 'INVALID_BADGE_NUMBER',
        ));

        return;
      }

      // Emit loading state
      emit(VerificationLoading(event.badgeNumber));

      // Call repository to verify badge
      final result = await repository.verifyBadge(
        event.badgeNumber.trim(),
        event.verificationType,
      );

      result.fold(
        // Handle failure
        (failure) {
          debugPrint('❌ Verification failed: ${failure.message}');
          emit(VerificationFailure(
            message: failure.message,
            badgeNumber: event.badgeNumber,
            code: failure.code,
          ));
        },
        // Handle success
        (response) {
          debugPrint('✅ Verification successful for badge: ${event.badgeNumber}');
          debugPrint('✅ Response: $response');
          
          emit(VerificationSuccess(
            response: response,
            badgeNumber: event.badgeNumber,
          ));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during verification: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      emit(VerificationFailure(
        message: 'An unexpected error occurred. Please try again.',
        badgeNumber: event.badgeNumber,
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  void _onResetVerificationState(
    ResetVerificationState event,
    Emitter<VerificationState> emit,
  ) {
    debugPrint('🔄 Resetting verification state');
    emit(const VerificationInitial());
  }
}