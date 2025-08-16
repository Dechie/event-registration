// lib/features/attendance_report/data/repositories/attendance_report_repository.dart
import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/features/attendance_report/data/datasource/attendance_report_datasource.dart';
import 'package:event_reg/features/attendance_report/data/models/attendance_report.dart';
import 'package:flutter/material.dart' show debugPrint;

abstract class AttendanceReportRepository {
  Future<Either<Failure, AttendanceReport>> getMyAttendanceReport();
}

class AttendanceReportRepositoryImpl implements AttendanceReportRepository {
  final AttendanceReportDataSource dataSource;
  final NetworkInfo networkInfo;

  AttendanceReportRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AttendanceReport>> getMyAttendanceReport() async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      debugPrint('🔍 Repository: Fetching attendance report...');
      
      final report = await dataSource.getMyAttendanceReport();
      
      debugPrint('✅ Repository: Attendance report fetched successfully');
      return Right(report);

    } on NetworkException catch (e) {
      debugPrint('❌ Repository Network error: ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint('❌ Repository Auth error: ${e.message}');
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      debugPrint('❌ Repository Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Repository Unexpected error: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}