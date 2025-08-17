// // lib/features/verification/data/repositories/verification_repository.dart

// import 'package:dartz/dartz.dart';
// import 'package:event_reg/core/services/user_data_service.dart';
// import 'package:event_reg/features/verification/data/datasource/verification_datasource.dart';
// import 'package:event_reg/features/verification/data/models/coupon.dart';
// import 'package:event_reg/injection_container.dart' as di;
// import 'package:flutter/material.dart' show debugPrint;

// import '../../../../core/error/exceptions.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/network/network_info.dart';
// import '../models/verification_response.dart';

// abstract class VerificationRepository {
//   Future<Either<Failure, List<Coupon>>> fetchParticipantCoupons(
//     String participantId,
//   );

//   Future<Either<Failure, VerificationResponse>> verifyBadge(
//     String badgeNumber,
//     String verificationType, {
//     String? eventSessionId,
//     String? sessionLocationId,
//     String? couponId,
//     String? eventId,
//   });
// }

// class VerificationRepositoryImpl implements VerificationRepository {
//   final VerificationRemoteDataSource remoteDataSource;
//   final NetworkInfo networkInfo;

//   VerificationRepositoryImpl({
//     required this.remoteDataSource,
//     required this.networkInfo,
//   });

//   @override
//   Future<Either<Failure, List<Coupon>>> fetchParticipantCoupons(
//     String participantId,
//   ) async {
//     try {
//       debugPrint(
//         '📡 Repository: Fetching coupons for participant: $participantId',
//       );

//       if (!await networkInfo.isConnected) {
//         return const Left(
//           NetworkFailure(
//             message:
//                 'No internet connection. Please check your network and try again.',
//             code: 'NO_INTERNET',
//           ),
//         );
//       }

//       final token = await di.sl<UserDataService>().getAuthToken() ?? "";
//       final coupons = await remoteDataSource.fetchParticipantCoupons(
//         participantId,
//         token,
//       );

//       return Right(coupons);
//     } catch (e) {
//       debugPrint('❌ Repository: Error fetching coupons - $e');

//       return Left(
//         ServerFailure(
//           message: 'Failed to fetch coupons. Please try again.',
//           code: 'FETCH_COUPONS_ERROR',
//         ),
//       );
//     }
//   }

//   @override
//   Future<Either<Failure, VerificationResponse>> verifyBadge(
//     String badgeNumber,
//     String verificationType, {
//     String? eventSessionId,
//     String? sessionLocationId,
//     String? couponId,
//     String? eventId,
//   }) async {
//     try {
//       debugPrint(
//         '📡 Repository: Verifying badge $badgeNumber for type: $verificationType',
//       );

//       // Check network connectivity
//       if (!await networkInfo.isConnected) {
//         debugPrint('❌ No internet connection');

//         return const Left(
//           NetworkFailure(
//             message:
//                 'No internet connection. Please check your network and try again.',
//             code: 'NO_INTERNET',
//           ),
//         );
//       }

//       // Call remote data source

//       final token = await di.sl<UserDataService>().getAuthToken() ?? "";
//       final response = await remoteDataSource.verifyBadge(
//         badgeNumber,
//         verificationType,
//         eventSessionId: eventSessionId,
//         sessionLocationId: sessionLocationId,
//         couponId: couponId,
//         token: token,
//       );
//       debugPrint('✅ Repository: Verification successful');

//       return Right(response);
//     } on ValidationException catch (e) {
//       debugPrint('❌ Repository: Validation error - ${e.message}');

//       return Left(
//         ValidationFailure(message: e.message, code: e.code, errors: e.errors),
//       );
//     } on AuthenticationException catch (e) {
//       debugPrint('❌ Repository: Authentication error - ${e.message}');

//       return Left(AuthenticationFailure(message: e.message, code: e.code));
//     } on AuthorizationException catch (e) {
//       debugPrint('❌ Repository: Authorization error - ${e.message}');

//       return Left(AuthorizationFailure(message: e.message, code: e.code));
//     } on ServerException catch (e) {
//       debugPrint('❌ Repository: Server error - ${e.message}');

//       return Left(ServerFailure(message: e.message, code: e.code));
//     } on NetworkException catch (e) {
//       debugPrint('❌ Repository: Network error - ${e.message}');

//       return Left(NetworkFailure(message: e.message, code: e.code));
//     } on TimeoutException catch (e) {
//       debugPrint('❌ Repository: Timeout error - ${e.message}');

//       return Left(TimeoutFailure(message: e.message, code: e.code));
//     } catch (e, stackTrace) {
//       debugPrint('❌ Repository: Unexpected error - $e');
//       debugPrint('❌ Stack trace: $stackTrace');

//       return Left(
//         UnknownFailure(
//           message:
//               'An unexpected error occurred during verification. Please try again.',
//           code: 'UNEXPECTED_REPOSITORY_ERROR',
//         ),
//       );
//     }
//   }
// }
// lib/features/verification/data/repositories/verification_repository.dart

import 'package:dartz/dartz.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/verification/data/datasource/verification_datasource.dart';
import 'package:event_reg/features/verification/data/models/coupon.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart' show debugPrint;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
// Import attendance models
import '../../../attendance/data/models/attendance_event_model.dart';
import '../models/verification_response.dart';

abstract class VerificationRepository {
  // Original verification methods
  Future<Either<Failure, List<Coupon>>> fetchParticipantCoupons(
    String participantId,
  );

  Future<Either<Failure, AttendanceEventModel>> getEventDetails(String eventId);

  // Merged attendance methods
  Future<Either<Failure, List<AttendanceEventModel>>> getEventsForAttendance();
  Future<Either<Failure, String>> markAttendanceForLocation({
    required String badgeNumber,
    required String eventSessionId,
    required String sessionLocationId,
  });
  Future<Either<Failure, VerificationResponse>> verifyBadge(
    String badgeNumber,
    String verificationType, {
    String? eventSessionId,
    String? sessionLocationId,
    String? couponId,
    String? eventId,
  });
}

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VerificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // Original verification methods
  @override
  Future<Either<Failure, List<Coupon>>> fetchParticipantCoupons(
    String participantId,
  ) async {
    try {
      debugPrint(
        '📡 Repository: Fetching coupons for participant: $participantId',
      );

      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
            code: 'NO_INTERNET',
          ),
        );
      }

      final token = await di.sl<UserDataService>().getAuthToken() ?? "";
      final coupons = await remoteDataSource.fetchParticipantCoupons(
        participantId,
        token,
      );

      return Right(coupons);
    } catch (e) {
      debugPrint('❌ Repository: Error fetching coupons - $e');

      return Left(
        ServerFailure(
          message: 'Failed to fetch coupons. Please try again.',
          code: 'FETCH_COUPONS_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AttendanceEventModel>> getEventDetails(
    String eventId,
  ) async {
    try {
      if (!await networkInfo.isConnected) {
        debugPrint('❌ No network connection available');
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      if (eventId.isEmpty) {
        debugPrint('❌ Empty event ID provided');
        return const Left(
          ValidationFailure(
            message: "Event ID is required",
            code: "VALIDATION_ERROR",
          ),
        );
      }

      debugPrint('📍 Repository: Fetching event details for ID: $eventId');
      final token = await di.sl<UserDataService>().getAuthToken() ?? "";
      final eventDetails = await remoteDataSource.fetchEventDetails(
        eventId,
        token,
      );
      debugPrint('✅ Repository: Successfully fetched event details');

      return Right(eventDetails);
    } on NetworkException catch (e) {
      debugPrint('❌ Network error during event details fetch: ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint(
        '❌ Authentication error during event details fetch: ${e.message}',
      );

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      debugPrint(
        '❌ Authorization error during event details fetch: ${e.message}',
      );
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint('❌ Validation error during event details fetch: ${e.message}');
      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error during event details fetch: ${e.message}');

      return Left(ServerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      debugPrint('❌ Cache error during event details fetch: ${e.message}');

      return Left(CacheFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error during event details fetch: ${e.message}');

      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during event details fetch: $e');

      return const Left(
        UnknownFailure(
          message: 'Failed to load event details. Please try again.',
          code: 'LOAD_EVENT_DETAILS_ERROR',
        ),
      );
    }
  }

  // Merged attendance methods
  @override
  Future<Either<Failure, List<AttendanceEventModel>>>
  getEventsForAttendance() async {
    try {
      if (!await networkInfo.isConnected) {
        debugPrint('❌ No network connection available');

        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      debugPrint('📍 Repository: Fetching events for attendance');
      final token = await di.sl<UserDataService>().getAuthToken() ?? "";
      final events = await remoteDataSource.fetchEventsForAttendance(token);
      debugPrint('✅ Repository: Successfully fetched ${events.length} events');

      return Right(events);
    } on NetworkException catch (e) {
      debugPrint('❌ Network error during events fetch: ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint('❌ Authentication error during events fetch: ${e.message}');

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      debugPrint('❌ Authorization error during events fetch: ${e.message}');

      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint('❌ Validation error during events fetch: ${e.message}');

      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error during events fetch: ${e.message}');

      return Left(ServerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      debugPrint('❌ Cache error during events fetch: ${e.message}');

      return Left(CacheFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error during events fetch: ${e.message}');

      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during events fetch: $e');

      return const Left(
        UnknownFailure(
          message: 'Failed to load events. Please try again.',
          code: 'LOAD_EVENTS_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> markAttendanceForLocation({
    required String badgeNumber,
    required String eventSessionId,
    required String sessionLocationId,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      if (badgeNumber.isEmpty ||
          eventSessionId.isEmpty ||
          sessionLocationId.isEmpty) {
        return const Left(
          ValidationFailure(
            message: "Badge number, session, and location are required.",
            code: "VALIDATION_ERROR",
          ),
        );
      }

      debugPrint(
        '📍 Attendance Repo: Marking attendance for badge: $badgeNumber',
      );
      final token = await di.sl<UserDataService>().getAuthToken() ?? "";
      await remoteDataSource.markAttendance(
        badgeNumber,
        eventSessionId,
        sessionLocationId,
        token,
      );
      debugPrint('✅ Attendance Repo: Successfully marked attendance');

      return const Right('Attendance marked successfully');
    } on ServerException catch (e) {
      debugPrint('❌ Attendance Repo: Server error - ${e.message}');

      // Specific error handling for attendance already taken
      if (e.message.contains('Attendace already taken for this person')) {
        return const Left(
          AttendanceAlreadyTakenFailure(
            message: "Attendance has already been taken for this participant.",
            code: "ATTENDANCE_ALREADY_TAKEN",
          ),
        );
      }

      return Left(ServerFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint('❌ Attendance Repo: Validation error - ${e.message}');

      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on AuthenticationException catch (e) {
      debugPrint('❌ Attendance Repo: Auth error - ${e.message}');

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      debugPrint('❌ Attendance Repo: Network error - ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Attendance Repo: Unexpected error - $e');

      return const Left(
        UnknownFailure(
          message: 'Failed to mark attendance. Please try again.',
          code: 'MARK_ATTENDANCE_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, VerificationResponse>> verifyBadge(
    String badgeNumber,
    String verificationType, {
    String? eventSessionId,
    String? sessionLocationId,
    String? couponId,
    String? eventId,
  }) async {
    try {
      debugPrint(
        '📡 Repository: Verifying badge $badgeNumber for type: $verificationType',
      );

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        debugPrint('❌ No internet connection');

        return const Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
            code: 'NO_INTERNET',
          ),
        );
      }

      // Call remote data source
      final token = await di.sl<UserDataService>().getAuthToken() ?? "";
      final response = await remoteDataSource.verifyBadge(
        badgeNumber,
        verificationType,
        eventSessionId: eventSessionId,
        sessionLocationId: sessionLocationId,
        couponId: couponId,
        token: token,
      );
      debugPrint('✅ Repository: Verification successful');

      return Right(response);
    } on ValidationException catch (e) {
      debugPrint('❌ Repository: Validation error - ${e.message}');
      
      return Left(
        ValidationFailure(message: e.message.replaceAll("person", "participant"), code: e.code, errors: e.errors),
      );
    } on AuthenticationException catch (e) {
      debugPrint('❌ Repository: Authentication error - ${e.message}');

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      debugPrint('❌ Repository: Authorization error - ${e.message}');

      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      debugPrint('❌ Repository: Server error - ${e.message}');

      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      debugPrint('❌ Repository: Network error - ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      debugPrint('❌ Repository: Timeout error - ${e.message}');

      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      debugPrint('❌ Repository: Unexpected error - $e');
      debugPrint('❌ Stack trace: $stackTrace');

      return Left(
        UnknownFailure(
          message:
              'An unexpected error occurred during verification. Please try again.',
          code: 'UNEXPECTED_REPOSITORY_ERROR',
        ),
      );
    }
  }
}
