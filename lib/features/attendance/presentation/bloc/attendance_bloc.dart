import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc({required this.repository}) : super(const AttendanceInitial()) {
    on<LoadEventsForAttendance>(_onLoadEventsForAttendance);
    on<LoadRoomsForSession>(_onLoadRoomsForSession);
    on<LoadSessionsForEvent>(_onLoadSessionsForEvent);
    on<MarkAttendance>(_onMarkAttendance);
  }

  Future<void> _onLoadEventsForAttendance(
    LoadEventsForAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading events for attendance');
      emit(const AttendanceLoading());

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
      emit(const AttendanceError(
        message: 'Failed to load events. Please try again.',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  Future<void> _onLoadRoomsForSession(
    LoadRoomsForSession event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading rooms for session: ${event.sessionId}');
      emit(const AttendanceLoading());

      final result = await repository.getRoomsForSession(event.sessionId);

      result.fold(
        (failure) {
          debugPrint('❌ Failed to load rooms: ${failure.message}');
          emit(AttendanceError(message: failure.message, code: failure.code));
        },
        (rooms) {
          debugPrint('✅ Rooms loaded successfully: ${rooms.length} rooms');
          emit(RoomsLoaded(rooms: rooms, sessionId: event.sessionId));
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error loading rooms: $e');
      emit(const AttendanceError(
        message: 'Failed to load rooms. Please try again.',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  Future<void> _onLoadSessionsForEvent(
    LoadSessionsForEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading sessions for event: ${event.eventId}');
      emit(const AttendanceLoading());

      final result = await repository.getSessionsForEvent(event.eventId);

      result.fold(
        (failure) {
          debugPrint('❌ Failed to load sessions: ${failure.message}');
          emit(AttendanceError(message: failure.message, code: failure.code));
        },
        (sessions) {
          debugPrint('✅ Sessions loaded successfully: ${sessions.length} sessions');
          emit(SessionsLoaded(sessions: sessions, eventId: event.eventId));
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error loading sessions: $e');
      emit(const AttendanceError(
        message: 'Failed to load sessions. Please try again.',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  Future<void> _onMarkAttendance(
    MarkAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      debugPrint('🔍 Marking attendance for participant: ${event.participantId}');
      
      final result = await repository.markAttendance(
        eventId: event.attendanceEventId,
        participantId: event.participantId,
        sessionId: event.sessionId,
        roomId: event.roomId,
      );

      result.fold(
        (failure) {
          debugPrint('❌ Failed to mark attendance: ${failure.message}');
          emit(AttendanceError(message: failure.message, code: failure.code));
        },
        (message) {
          debugPrint('✅ Attendance marked successfully');
          emit(AttendanceMarked(
            participantId: event.participantId,
            sessionId: event.sessionId,
            roomId: event.roomId,
            message: message,
          ));
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error marking attendance: $e');
      emit(const AttendanceError(
        message: 'Failed to mark attendance. Please try again.',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }
}
