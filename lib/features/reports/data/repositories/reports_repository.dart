import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../datasource/reports_datasource.dart';
import '../models/event_report.dart';
import '../models/session_report.dart';

abstract class ReportRepository {
  Future<Either<Failure, EventReport>> getEventReport(int eventId);
  Future<Either<Failure, SessionReport>> getSessionReport(int sessionId);
}

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, EventReport>> getEventReport(int eventId) async {
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

      if (eventId <= 0) {
        debugPrint('❌ Invalid event ID provided: $eventId');
        return const Left(
          ValidationFailure(
            message: "Valid event ID is required",
            code: "VALIDATION_ERROR",
          ),
        );
      }

      debugPrint('🔍 Repository: Fetching event report for ID: $eventId');
      final eventReport = await remoteDataSource.fetchEventReport(eventId);
      debugPrint('✅ Repository: Successfully fetched event report');

      return Right(eventReport);
    } on NetworkException catch (e) {
      debugPrint('❌ Network error during event report fetch: ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint(
        '❌ Authentication error during event report fetch: ${e.message}',
      );
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      debugPrint(
        '❌ Authorization error during event report fetch: ${e.message}',
      );
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint('❌ Validation error during event report fetch: ${e.message}');
      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error during event report fetch: ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error during event report fetch: ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during event report fetch: $e');
      return const Left(
        UnknownFailure(
          message: 'Failed to load event report. Please try again.',
          code: 'LOAD_EVENT_REPORT_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SessionReport>> getSessionReport(int sessionId) async {
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

      if (sessionId <= 0) {
        debugPrint('❌ Invalid session ID provided: $sessionId');
        return const Left(
          ValidationFailure(
            message: "Valid session ID is required",
            code: "VALIDATION_ERROR",
          ),
        );
      }

      debugPrint('🔍 Repository: Fetching session report for ID: $sessionId');
      final sessionReport = await remoteDataSource.fetchSessionReport(
        sessionId,
      );
      debugPrint('✅ Repository: Successfully fetched session report');

      return Right(sessionReport);
    } on NetworkException catch (e) {
      debugPrint('❌ Network error during session report fetch: ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint(
        '❌ Authentication error during session report fetch: ${e.message}',
      );
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      debugPrint(
        '❌ Authorization error during session report fetch: ${e.message}',
      );
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      debugPrint(
        '❌ Validation error during session report fetch: ${e.message}',
      );
      return Left(
        ValidationFailure(message: e.message, code: e.code, errors: e.errors),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error during session report fetch: ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error during session report fetch: ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during session report fetch: $e');
      return const Left(
        UnknownFailure(
          message: 'Failed to load session report. Please try again.',
          code: 'LOAD_SESSION_REPORT_ERROR',
        ),
      );
    }
  }
}
