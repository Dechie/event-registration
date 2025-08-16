// lib/features/reports/presentation/bloc/report_event.dart
import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventReport extends ReportEvent {
  final int eventId;

  const LoadEventReport(this.eventId);

  @override
  List<Object?> get props => [eventId];

  @override
  String toString() => 'LoadEventReport(eventId: $eventId)';
}

class LoadSessionReport extends ReportEvent {
  final int sessionId;

  const LoadSessionReport(this.sessionId);

  @override
  List<Object?> get props => [sessionId];

  @override
  String toString() => 'LoadSessionReport(sessionId: $sessionId)';
}

class RefreshReports extends ReportEvent {
  const RefreshReports();

  @override
  String toString() => 'RefreshReports()';
}

