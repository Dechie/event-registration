import 'package:dartz/dartz.dart';
import 'package:event_reg/core/network/network_info.dart';
import '../../../../core/error/failures.dart';
import '../datasource/attendance_datasource.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_room.dart';
import '../models/attendance_session.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, List<AttendanceEventModel>>> getEventsForAttendance();
  Future<Either<Failure, List<AttendanceRoom>>> getRoomsForSession(String sessionId);
  Future<Either<Failure, List<AttendanceSession>>> getSessionsForEvent(String eventId);
  Future<Either<Failure, String>> markAttendance({
    required String participantId,
    required String sessionId,
    required String roomId,
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
  Future<Either<Failure, List<AttendanceEventModel>>> getEventsForAttendance() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NO_INTERNET',
        ));
      }

      final events = await remoteDataSource.getEventsForAttendance();
      return Right(events);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to load events. Please try again.',
        code: 'LOAD_EVENTS_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRoom>>> getRoomsForSession(String sessionId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NO_INTERNET',
        ));
      }

      final rooms = await remoteDataSource.getRoomsForSession(sessionId);
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to load rooms. Please try again.',
        code: 'LOAD_ROOMS_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceSession>>> getSessionsForEvent(String eventId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NO_INTERNET',
        ));
      }

      final sessions = await remoteDataSource.getSessionsForEvent(eventId);
      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to load sessions. Please try again.',
        code: 'LOAD_SESSIONS_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> markAttendance({
    required String participantId,
    required String sessionId,
    required String roomId,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NO_INTERNET',
        ));
      }

      final message = await remoteDataSource.markAttendance(
        participantId: participantId,
        sessionId: sessionId,
        roomId: roomId,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to mark attendance. Please try again.',
        code: 'MARK_ATTENDANCE_ERROR',
      ));
    }
  }
}