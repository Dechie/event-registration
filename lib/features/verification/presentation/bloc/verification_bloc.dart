// // lib/features/verification/presentation/bloc/verification_bloc.dart

// import 'package:flutter/material.dart' show debugPrint;
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../attendance/presentation/bloc/attendance_bloc.dart';
// import '../../../attendance/presentation/bloc/attendance_event.dart';
// import '../../data/repositories/verification_repository.dart';
// import 'verification_event.dart';
// import 'verification_state.dart';

// class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
//   final VerificationRepository repository;
//   final AttendanceBloc? attendanceBloc; // Optional dependency for attendance

//   VerificationBloc({required this.repository, this.attendanceBloc})
//     : super(const VerificationInitial()) {
//     on<VerifyBadgeRequested>(_onVerifyBadgeRequested);
//     on<ResetVerificationState>(_onResetVerificationState);
//     on<FetchParticipantCoupons>(_onFetchParticipantCoupons);
//   }

//   Future<void> _onFetchParticipantCoupons(
//     FetchParticipantCoupons event,
//     Emitter<VerificationState> emit,
//   ) async {
//     try {
//       debugPrint('🔍 Fetching coupons for participant: ${event.participantId}');

//       emit(VerificationLoading(event.participantId));

//       final result = await repository.fetchParticipantCoupons(
//         event.participantId,
//       );

//       result.fold(
//         (failure) {
//           debugPrint('❌ Failed to fetch coupons: ${failure.message}');
//           emit(
//             VerificationFailure(
//               message: failure.message,
//               badgeNumber: event.participantId,
//               code: failure.code,
//             ),
//           );
//         },
//         (coupons) {
//           debugPrint(
//             '✅ Coupons fetched successfully: ${coupons.length} coupons',
//           );
//           emit(
//             CouponsFetched(
//               coupons: coupons,
//               participantId: event.participantId,
//               participant: event.participant, // Add this line
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       debugPrint('❌ Unexpected error fetching coupons: $e');
//       emit(
//         VerificationFailure(
//           message: 'Failed to fetch coupons. Please try again.',
//           badgeNumber: event.participantId,
//           code: 'UNEXPECTED_ERROR',
//         ),
//       );
//     }
//   }
//   // Add this method

//   void _onResetVerificationState(
//     ResetVerificationState event,
//     Emitter<VerificationState> emit,
//   ) {
//     debugPrint('🔄 Resetting verification state');
//     emit(const VerificationInitial());
//   }

//   Future<void> _onVerifyBadgeRequested(
//     VerifyBadgeRequested event,
//     Emitter<VerificationState> emit,
//   ) async {
//     try {
//       debugPrint(
//         '🔍 Starting verification for badge:  ${event.badgeNumber} (type: ${event.verificationType})',
//       );

//       // Validate badge number
//       if (event.badgeNumber.trim().isEmpty) {
//         emit(
//           VerificationFailure(
//             message: 'Badge number cannot be empty',
//             badgeNumber: event.badgeNumber,
//             code: 'INVALID_BADGE_NUMBER',
//           ),
//         );

//         return;
//       }

//       // Emit loading state
//       emit(VerificationLoading(event.badgeNumber));

//       // Call repository to verify badge, passing extra data if present
//       debugPrint(
//         "verification bloc: data: badgeNumber: ${event.badgeNumber}, type: ${event.verificationType}",
//       );
//       final result = await repository.verifyBadge(
//         event.badgeNumber.trim(),
//         event.verificationType,
//         eventSessionId: event.eventSessionId,
//         sessionLocationId: event.sessionLocationId ?? event.roomId,
//         couponId: event.couponId,
//         eventId: event.eventId,
//       );

//       result.fold(
//         // Handle failure
//         (failure) {
//           debugPrint('❌ Verification failed: ${failure.message}');
//           emit(
//             VerificationFailure(
//               message: failure.message,
//               badgeNumber: event.badgeNumber,
//               code: failure.code,
//             ),
//           );
//         },
//         // Handle success
//         (response) {
//           debugPrint(
//             '✅ Verification successful for badge: ${event.badgeNumber}',
//           );

//           // If this is an attendance verification and we have an attendance bloc,
//           // mark attendance after successful verification
//           if (event.verificationType.toLowerCase() == 'attendance' &&
//               attendanceBloc != null &&
//               response.participant != null) {
//             debugPrint(
//               '🎯 Marking attendance for participant: ${response.participant!.id}',
//             );

//             // Mark attendance using the attendance bloc
//             attendanceBloc!.add(
//               MarkAttendanceForLocation(
//                 badgeNumber: event.badgeNumber,
//                 eventSessionId: event.eventSessionId ?? '',
//                 sessionLocationId:
//                     event.roomId ?? '', // Use roomId from the event
//               ),
//             );
//           }

//           emit(
//             VerificationSuccess(
//               response: response,
//               badgeNumber: event.badgeNumber,
//             ),
//           );
//         },
//       );
//     } catch (e, stackTrace) {
//       debugPrint('❌ Unexpected error during verification: $e');
//       debugPrint('❌ Stack trace: $stackTrace');

//       emit(
//         VerificationFailure(
//           message: 'An unexpected error occurred. Please try again.',
//           badgeNumber: event.badgeNumber,
//           code: 'UNEXPECTED_ERROR',
//         ),
//       );
//     }
//   }
// }
// lib/features/verification/presentation/bloc/verification_bloc.dart

import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/verification_repository.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository repository;

  VerificationBloc({required this.repository})
      : super(const VerificationInitial()) {
    // Original verification events
    on<VerifyBadgeRequested>(_onVerifyBadgeRequested);
    on<ResetVerificationState>(_onResetVerificationState);
    on<FetchParticipantCoupons>(_onFetchParticipantCoupons);
    
    // Merged attendance events
    on<LoadEventsForAttendance>(_onLoadEventsForAttendance);
    on<LoadEventDetails>(_onLoadEventDetails);
    on<MarkAttendanceForLocation>(_onMarkAttendanceForLocation);
  }

  // Original verification event handlers
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
              participant: event.participant,
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
        '🔍 Starting verification for badge: ${event.badgeNumber} (type: ${event.verificationType})',
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

          // If this is an attendance verification, also mark attendance
          if (event.verificationType.toLowerCase() == 'attendance' &&
              response.participant != null) {
            debugPrint(
              '🎯 Marking attendance for participant: ${response.participant!.id}',
            );

            // Trigger attendance marking after successful verification
            add(
              MarkAttendanceForLocation(
                badgeNumber: event.badgeNumber,
                eventSessionId: event.eventSessionId ?? '',
                sessionLocationId: event.roomId ?? '',
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

  // Merged attendance event handlers
  Future<void> _onLoadEventsForAttendance(
    LoadEventsForAttendance event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading events for attendance');
      emit(VerificationLoading(''));

      final result = await repository.getEventsForAttendance();

      result.fold(
        (failure) {
          debugPrint('❌ Failed to load events: ${failure.message}');
          emit(AttendanceError(message: failure.message, code: failure.code));
        },
        (events) {
          debugPrint('✅ Events loaded successfully: ${events.length} events');
          emit(EventsLoaded(events));
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error loading events: $e');
      emit(
        const AttendanceError(
          message: 'Failed to load events. Please try again.',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadEventDetails(
    LoadEventDetails event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading detailed event info for: ${event.eventId}');
      emit(VerificationLoading(''));

      final result = await repository.getEventDetails(event.eventId);

      result.fold(
        (failure) {
          debugPrint('❌ Failed to load event details: ${failure.message}');
          emit(AttendanceError(message: failure.message, code: failure.code));
        },
        (eventModel) {
          debugPrint('✅ Event details loaded successfully');
          emit(EventDetailsLoaded(eventModel));
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error loading event details: $e');
      emit(
        const AttendanceError(
          message: 'Failed to load event details. Please try again.',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  Future<void> _onMarkAttendanceForLocation(
    MarkAttendanceForLocation event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      debugPrint(
        '🔍 Verification Bloc: Marking attendance for badge: ${event.badgeNumber}',
      );
      
      // Don't emit loading here if we're already in a verification success state
      // to avoid overriding the verification success UI
      if (state is! VerificationSuccess) {
        emit(VerificationLoading(event.badgeNumber));
      }

      final result = await repository.markAttendanceForLocation(
        badgeNumber: event.badgeNumber,
        eventSessionId: event.eventSessionId,
        sessionLocationId: event.sessionLocationId,
      );

      result.fold(
        (failure) {
          debugPrint(
            '❌ Verification Bloc: Failed to mark attendance - ${failure.message}',
          );
          // Emit the specific failure from the repository
          emit(AttendanceError(message: failure.message, code: failure.code));
        },
        (message) {
          debugPrint('✅ Verification Bloc: Attendance marked successfully');
          emit(
            AttendanceMarkedForLocation(
              badgeNumber: event.badgeNumber,
              eventSessionId: event.eventSessionId,
              sessionLocationId: event.sessionLocationId,
              message: message,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Verification Bloc: Unexpected error - $e');
      emit(
        const AttendanceError(
          message: 'Failed to mark attendance. Please try again.',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }
}
