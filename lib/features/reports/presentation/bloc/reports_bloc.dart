import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/reports_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc({required this.repository}) : super(ReportInitial()) {
    on<LoadEventReport>(_onLoadEventReport);
    on<LoadSessionReport>(_onLoadSessionReport);
    on<RefreshReports>(_onRefreshReports);
  }

  Future<void> _onLoadEventReport(
    LoadEventReport event,
    Emitter<ReportState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading event report for: ${event.eventId}');
      emit(ReportLoading());

      final result = await repository.getEventReport(event.eventId);

      result.fold(
        (failure) {
          debugPrint('❌ Failed to load event report: ${failure.message}');
          emit(ReportError(message: failure.message, code: failure.code));
        },
        (eventReport) {
          debugPrint('✅ Event report loaded successfully');
          emit(EventReportLoaded(eventReport));
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error loading event report: $e');
      emit(
        const ReportError(
          message: 'Failed to load event report. Please try again.',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadSessionReport(
    LoadSessionReport event,
    Emitter<ReportState> emit,
  ) async {
    try {
      debugPrint('🔍 Loading session report for: ${event.sessionId}');
      emit(ReportLoading());

      final result = await repository.getSessionReport(event.sessionId);

      result.fold(
        (failure) {
          debugPrint('❌ Failed to load session report: ${failure.message}');
          emit(ReportError(message: failure.message, code: failure.code));
        },
        (sessionReport) {
          debugPrint('✅ Session report loaded successfully');
          emit(SessionReportLoaded(sessionReport));
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error loading session report: $e');
      emit(
        const ReportError(
          message: 'Failed to load session report. Please try again.',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  Future<void> _onRefreshReports(
    RefreshReports event,
    Emitter<ReportState> emit,
  ) async {
    // Reset to initial state to allow fresh loading
    emit(ReportInitial());
  }
}
