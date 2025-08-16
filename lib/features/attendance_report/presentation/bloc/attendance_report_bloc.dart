// lib/features/attendance_report/presentation/bloc/attendance_report_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_reg/features/attendance_report/data/repositories/attendance_report_repository.dart';
import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_event.dart';
import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_state.dart';
import 'package:flutter/material.dart' show debugPrint;

class AttendanceReportBloc extends Bloc<AttendanceReportEvent, AttendanceReportState> {
  final AttendanceReportRepository repository;

  AttendanceReportBloc({required this.repository}) : super(const AttendanceReportInitial()) {
    on<FetchAttendanceReportRequested>(_onFetchAttendanceReport);
    on<RefreshAttendanceReportRequested>(_onRefreshAttendanceReport);
  }

  Future<void> _onFetchAttendanceReport(
    FetchAttendanceReportRequested event,
    Emitter<AttendanceReportState> emit,
  ) async {
    emit(const AttendanceReportLoading());
    await _fetchReport(emit);
  }

  Future<void> _onRefreshAttendanceReport(
    RefreshAttendanceReportRequested event,
    Emitter<AttendanceReportState> emit,
  ) async {
    // Don't show loading for refresh, keep current data visible
    await _fetchReport(emit);
  }

  Future<void> _fetchReport(Emitter<AttendanceReportState> emit) async {
    try {
      debugPrint('🔍 BLoC: Fetching attendance report...');
      
      final result = await repository.getMyAttendanceReport();
      
      result.fold(
        (failure) {
          debugPrint('❌ BLoC: Failed to fetch attendance report: ${failure.message}');
          emit(AttendanceReportError(message: failure.message));
        },
        (report) {
          debugPrint('✅ BLoC: Attendance report loaded successfully');
          debugPrint('📊 Report for: ${report.participantName}');
          debugPrint('📈 Total sessions: ${report.aggregatedStats.totalSessions}');
          emit(AttendanceReportLoaded(report: report));
        },
      );
    } catch (e) {
      debugPrint('❌ BLoC: Unexpected error: $e');
      emit(AttendanceReportError(message: 'An unexpected error occurred'));
    }
  }
}