// lib/features/verification/presentation/bloc/verification_bloc.dart

import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../attendance/presentation/bloc/attendance_event.dart';
import '../../data/repositories/verification_repository.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository repository;
  final AttendanceBloc? attendanceBloc; // Optional dependency for attendance

  VerificationBloc({required this.repository, this.attendanceBloc})
    : super(const VerificationInitial()) {
    on<VerifyBadgeRequested>(_onVerifyBadgeRequested);
    on<ResetVerificationState>(_onResetVerificationState);
    on<FetchParticipantCoupons>(_onFetchParticipantCoupons);
  }

  Future<void> _onFetchParticipantCoupons(
    FetchParticipantCoupons event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      debugPrint('🔍 Fetching coupons for participant: ${event.participantId}');

      emit(VerificationLoading(event.participantId));

      final result = await repository.fetchParticipantCoupons(
        event.participantId,
      );

      result.fold(
        (failure) {
          debugPrint('❌ Failed to fetch coupons: ${failure.message}');
          emit(
            VerificationFailure(
              message: failure.message,
              badgeNumber: event.participantId,
              code: failure.code,
            ),
          );
        },
        (coupons) {
          debugPrint(
            '✅ Coupons fetched successfully: ${coupons.length} coupons',
          );
          emit(
            CouponsFetched(
              coupons: coupons,
              participantId: event.participantId,
              participant: event.participant, // Add this line
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error fetching coupons: $e');
      emit(
        VerificationFailure(
          message: 'Failed to fetch coupons. Please try again.',
          badgeNumber: event.participantId,
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }
  // Add this method

  void _onResetVerificationState(
    ResetVerificationState event,
    Emitter<VerificationState> emit,
  ) {
    debugPrint('🔄 Resetting verification state');
    emit(const VerificationInitial());
  }

  Future<void> _onVerifyBadgeRequested(
    VerifyBadgeRequested event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      debugPrint(
        '🔍 Starting verification for badge:  ${event.badgeNumber} (type: ${event.verificationType})',
      );

      // Validate badge number
      if (event.badgeNumber.trim().isEmpty) {
        emit(
          VerificationFailure(
            message: 'Badge number cannot be empty',
            badgeNumber: event.badgeNumber,
            code: 'INVALID_BADGE_NUMBER',
          ),
        );

        return;
      }

      // Emit loading state
      emit(VerificationLoading(event.badgeNumber));

      // Call repository to verify badge, passing extra data if present
      debugPrint(
        "verification bloc: data: badgeNumber: ${event.badgeNumber}, type: ${event.verificationType}",
      );
      final result = await repository.verifyBadge(
        event.badgeNumber.trim(),
        event.verificationType,
        eventSessionId: event.eventSessionId,
        sessionLocationId: event.sessionLocationId ?? event.roomId,
        couponId: event.couponId,
        eventId: event.eventId,
      );

      result.fold(
        // Handle failure
        (failure) {
          debugPrint('❌ Verification failed: ${failure.message}');
          emit(
            VerificationFailure(
              message: failure.message,
              badgeNumber: event.badgeNumber,
              code: failure.code,
            ),
          );
        },
        // Handle success
        (response) {
          debugPrint(
            '✅ Verification successful for badge: ${event.badgeNumber}',
          );

          // If this is an attendance verification and we have an attendance bloc,
          // mark attendance after successful verification
          if (event.verificationType.toLowerCase() == 'attendance' &&
              attendanceBloc != null &&
              response.participant != null) {
            debugPrint(
              '🎯 Marking attendance for participant: ${response.participant!.id}',
            );

            // Mark attendance using the attendance bloc
            attendanceBloc!.add(
              MarkAttendanceForLocation(
                badgeNumber: event.badgeNumber,
                eventSessionId: event.eventSessionId ?? '',
                sessionLocationId:
                    event.roomId ?? '', // Use roomId from the event
              ),
            );
          }

          emit(
            VerificationSuccess(
              response: response,
              badgeNumber: event.badgeNumber,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during verification: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      emit(
        VerificationFailure(
          message: 'An unexpected error occurred. Please try again.',
          badgeNumber: event.badgeNumber,
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }
}
