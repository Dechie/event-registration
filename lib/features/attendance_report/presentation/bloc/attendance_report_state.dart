// lib/features/attendance_report/presentation/bloc/attendance_report_state.dart
import 'package:event_reg/features/attendance_report/data/models/attendance_report.dart';

abstract class AttendanceReportState {
  const AttendanceReportState();
}

class AttendanceReportInitial extends AttendanceReportState {
  const AttendanceReportInitial();
}

class AttendanceReportLoading extends AttendanceReportState {
  const AttendanceReportLoading();
}

class AttendanceReportLoaded extends AttendanceReportState {
  final AttendanceReport report;

  const AttendanceReportLoaded({required this.report});
}

class AttendanceReportError extends AttendanceReportState {
  final String message;

  const AttendanceReportError({required this.message});
}


