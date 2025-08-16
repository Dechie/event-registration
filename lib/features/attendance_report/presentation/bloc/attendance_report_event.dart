// lib/features/attendance_report/presentation/bloc/attendance_report_event.dart
abstract class AttendanceReportEvent {
  const AttendanceReportEvent();
}

class FetchAttendanceReportRequested extends AttendanceReportEvent {
  const FetchAttendanceReportRequested();
}

class RefreshAttendanceReportRequested extends AttendanceReportEvent {
  const RefreshAttendanceReportRequested();
}

