import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasource/attendance_datasource.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_room.dart';
import '../models/attendance_session.dart';

// You'll also need to create the AttendanceRemoteDataSource
abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceEventModel>> getEventsForAttendance();
  Future<List<AttendanceSession>> getSessionsForEvent(String eventId);
  Future<List<AttendanceRoom>> getRoomsForSession(String sessionId);
  Future<String> markAttendance({
    required String participantId,
    required String sessionId,
    required String roomId,
  });
}