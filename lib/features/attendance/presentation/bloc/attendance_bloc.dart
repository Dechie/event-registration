import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc({required this.repository}) : super(AttendanceInitial()) {
    on<LoadEventsForAttendance>(_onLoadEventsForAttendance);
    on<LoadEventDetails>(_onLoadEventDetails);
    on<MarkAttendanceForLocation>(_onMarkAttendanceForLocation);
  }

  Future<void> _onLoadEventsForAttendance(
    LoadEventsForAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading events for attendance');
      emit(AttendanceLoading());

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

  Future<void> _onLoadEventDetails(
    LoadEventDetails event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading detailed event info for: ${event.eventId}');
      emit(AttendanceLoading());

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
      emit(const AttendanceError(
        message: 'Failed to load event details. Please try again.',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  Future<void> _onMarkAttendanceForLocation(
    MarkAttendanceForLocation event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      debugPrint('🔍 Marking attendance for badge: ${event.badgeNumber}');
      
      final result = await repository.markAttendanceForLocation(
        badgeNumber: event.badgeNumber,
        eventSessionId: event.eventSessionId,
        sessionLocationId: event.sessionLocationId,
      );

      result.fold(
        (failure) {
          debugPrint('❌ Failed to mark attendance: ${failure.message}');
          emit(AttendanceError(message: failure.message, code: failure.code));
        },
        (message) {
          debugPrint('✅ Attendance marked successfully');
          emit(AttendanceMarkedForLocation(
            badgeNumber: event.badgeNumber,
            eventSessionId: event.eventSessionId,
            sessionLocationId: event.sessionLocationId,
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