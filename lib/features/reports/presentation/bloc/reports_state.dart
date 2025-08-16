// lib/features/reports/presentation/bloc/report_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/event_report.dart';
import '../../data/models/session_report.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class EventReportLoaded extends ReportState {
  final EventReport eventReport;

  const EventReportLoaded(this.eventReport);

  @override
  List<Object?> get props => [eventReport];

  @override
  String toString() => 'EventReportLoaded(eventId: ${eventReport.eventId})';
}

class SessionReportLoaded extends ReportState {
  final SessionReport sessionReport;

  const SessionReportLoaded(this.sessionReport);

  @override
  List<Object?> get props => [sessionReport];

  @override
  String toString() => 'SessionReportLoaded(sessionId: ${sessionReport.sessionId})';
}

class ReportError extends ReportState {
  final String message;
  final String? code;

  const ReportError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'ReportError(message: $message, code: $code)';
}

