// import 'package:dartz/dartz.dart';
// import 'package:event_reg/core/network/network_info.dart';
// import 'package:event_reg/core/services/user_data_service.dart';
// import '../../../../core/error/failures.dart';
// import '../datasource/attendance_datasource.dart';
// import '../models/attendance_event_model.dart';

// abstract class AttendanceRepository {
//   Future<Either<Failure, List<AttendanceEventModel>>> getEventsForAttendance();
//   Future<Either<Failure, AttendanceEventModel>> getEventDetails(String eventId);
//   Future<Either<Failure, String>> markAttendanceForLocation({
//     required String badgeNumber,
//     required String eventSessionId,
//     required String sessionLocationId,
//   });
// }

// class AttendanceRepositoryImpl implements AttendanceRepository {
//   final AttendanceRemoteDataSource remoteDataSource;
//   final NetworkInfo networkInfo;

//   AttendanceRepositoryImpl({
//     required this.remoteDataSource,
//     required this.networkInfo,
//   });

//   @override
//   Future<Either<Failure, List<AttendanceEventModel>>> getEventsForAttendance() async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(NetworkFailure(
//           message: 'No internet connection. Please check your network and try again.',
//           code: 'NO_INTERNET',
//         ));
//       }

//       final events = await remoteDataSource.fetchEventsForAttendance();
//       return Right(events);
//     } catch (e) {
//       return Left(ServerFailure(
//         message: 'Failed to load events. Please try again.',
//         code: 'LOAD_EVENTS_ERROR',
//       ));
//     }
//   }

//   @override
//   Future<Either<Failure, AttendanceEventModel>> getEventDetails(String eventId) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(NetworkFailure(
//           message: 'No internet connection. Please check your network and try again.',
//           code: 'NO_INTERNET',
//         ));
//       }

//       final eventDetails = await remoteDataSource.fetchEventDetails(eventId);
//       return Right(eventDetails);
//     } catch (e) {
//       return Left(ServerFailure(
//         message: 'Failed to load event details. Please try again.',
//         code: 'LOAD_EVENT_DETAILS_ERROR',
//       ));
//     }
//   }

//   @override
//   Future<Either<Failure, String>> markAttendanceForLocation({
//     required String badgeNumber,
//     required String eventSessionId,
//     required String sessionLocationId,
//   }) async {
//     try {
//       if (!await networkInfo.isConnected) {
//         return const Left(NetworkFailure(
//           message: 'No internet connection. Please check your network and try again.',
//           code: 'NO_INTERNET',
//         ));
//       }

//       await remoteDataSource.markAttendance(
//         badgeNumber,
//         eventSessionId,
//         sessionLocationId,
//       );

//       return const Right('Attendance marked successfully');
//     } catch (e) {
//       return Left(ServerFailure(
//         message: 'Failed to mark attendance. Please try again.',
//         code: 'MARK_ATTENDANCE_ERROR',
//       ));
//     }
//   }
// }
import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../datasource/attendance_datasource.dart';
import '../models/attendance_event_model.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEventModel>> getEventDetails(String eventId);
  Future<Either<Failure, List<AttendanceEventModel>>> getEventsForAttendance();
  Future<Either<Failure, String>> markAttendanceForLocation({
    required String badgeNumber,
    required String eventSessionId,
    required String sessionLocationId,
  });
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

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

      debugPrint('🔍 Repository: Fetching event details for ID: $eventId');
      final eventDetails = await remoteDataSource.fetchEventDetails(eventId);
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

      debugPrint('🔍 Repository: Fetching events for attendance');
      final events = await remoteDataSource.fetchEventsForAttendance();
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
        debugPrint('❌ No network connection available');
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      // Validate required parameters
      if (badgeNumber.isEmpty) {
        debugPrint('❌ Empty badge number provided');
        return const Left(
          ValidationFailure(
            message: "Badge number is required",
            code: "VALIDATION_ERROR",
          ),
        );
      }

      if (eventSessionId.isEmpty) {
        debugPrint('❌ Empty event session ID provided');
        return const Left(
          ValidationFailure(
            message: "Event session ID is required",
            code: "VALIDATION_ERROR",
          ),
        );
      }

      if (sessionLocationId.isEmpty) {
        debugPrint('❌ Empty session location ID provided');
        return const Left(
          ValidationFailure(
            message: "Session location ID is required",
            code: "VALIDATION_ERROR",
          ),
        );
      }

      // Check authentication token

      debugPrint('🔍 Repository: Marking attendance for badge: $badgeNumber');
      await remoteDataSource.markAttendance(
        badgeNumber,
        eventSessionId,
        sessionLocationId,
      );
      debugPrint('✅ Repository: Successfully marked attendance');

      return const Right('Attendance marked successfully');
    } on NetworkException catch (e) {
      debugPrint('❌ Network error during attendance marking: ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint(
        '❌ Authentication error during attendance marking: ${e.message}',
      );
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      debugPrint(
        '❌ Authorization error during attendance marking: ${e.message}',
      );
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint('❌ Validation error during attendance marking: ${e.message}');
      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error during attendance marking: ${e.message}');

      // Handle specific attendance-related errors
      if (e.code == "ATTENDANCE_ALREADY_MARKED") {
        return Left(
          ValidationFailure(
            message: "Attendance already marked for this session",
            code: "ATTENDANCE_ALREADY_MARKED",
          ),
        );
      } else if (e.code == "INVALID_BADGE_NUMBER") {
        return Left(
          ValidationFailure(
            message: "Invalid badge number",
            code: "INVALID_BADGE_NUMBER",
          ),
        );
      } else if (e.code == "SESSION_NOT_ACTIVE") {
        return Left(
          ValidationFailure(
            message: "This session is not currently active",
            code: "SESSION_NOT_ACTIVE",
          ),
        );
      }

      return Left(ServerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      debugPrint('❌ Cache error during attendance marking: ${e.message}');
      return Left(CacheFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error during attendance marking: ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during attendance marking: $e');
      return const Left(
        UnknownFailure(
          message: 'Failed to mark attendance. Please try again.',
          code: 'MARK_ATTENDANCE_ERROR',
        ),
      );
    }
  }
}
