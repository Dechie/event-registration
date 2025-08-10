// lib/features/attendance/data/datasource/attendance_datasource.dart
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../models/attendance_event_model.dart';
import '../models/attendance_room.dart';
import '../models/attendance_session.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceEventModel>> getEventsForAttendance();
  Future<List<AttendanceRoom>> getRoomsForSession(String sessionId);
  Future<List<AttendanceSession>> getSessionsForEvent(String eventId);
  Future<String> markAttendance({
    required String participantId,
    required String sessionId,
    required String roomId,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient dioClient;
  final UserDataService userDataService;

  AttendanceRemoteDataSourceImpl({
    required this.dioClient,
    required this.userDataService,
  });

  @override
  Future<List<AttendanceEventModel>> getEventsForAttendance() async {
    try {
      debugPrint('🚀 DataSource: Fetching events for attendance');

      final token = await userDataService.getAuthToken() ?? '';
      final response = await dioClient.get(
        "/events",
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data is Map<String, dynamic>
            ? (data["data"] ?? data["events"] ?? [])
            : data;

        if (eventsData is List) {
          return eventsData
              .map((eventJson) => AttendanceEventModel.fromJson(eventJson))
              .toList();
        } else {
          debugPrint('⚠️ DataSource: Unexpected events data format, using mock data');
          return _getMockEvents();
        }
      } else {
        throw Exception("Failed to fetch events for attendance: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('❌ DataSource: Error fetching events - $e');
      // For demo purposes, return mock data instead of throwing
      return _getMockEvents();
    }
  }

  @override
  Future<List<AttendanceRoom>> getRoomsForSession(String sessionId) async {
    try {
      debugPrint('🚀 DataSource: Fetching rooms for session $sessionId');

      final token = await userDataService.getAuthToken() ?? '';
      final response = await dioClient.get(
        "/sessions/$sessionId/rooms",
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final roomsData = data is Map<String, dynamic>
            ? (data["data"] ?? data["rooms"] ?? [])
            : data;

        if (roomsData is List) {
          return roomsData
              .map((roomJson) => AttendanceRoom.fromJson(roomJson))
              .toList();
        } else {
          debugPrint('⚠️ DataSource: Unexpected rooms data format, using mock data');
          return _getMockRooms(sessionId);
        }
      } else {
        throw Exception("Failed to fetch rooms for session: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('❌ DataSource: Error fetching rooms - $e');
      // For demo purposes, return mock data instead of throwing
      return _getMockRooms(sessionId);
    }
  }

  @override
  Future<List<AttendanceSession>> getSessionsForEvent(String eventId) async {
    try {
      debugPrint('🚀 DataSource: Fetching sessions for event $eventId');

      final token = await userDataService.getAuthToken() ?? '';
      final response = await dioClient.get(
        "/events/$eventId/sessions",
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final sessionsData = data is Map<String, dynamic>
            ? (data["data"] ?? data["sessions"] ?? [])
            : data;

        if (sessionsData is List) {
          return sessionsData
              .map((sessionJson) => AttendanceSession.fromJson(sessionJson))
              .toList();
        } else {
          debugPrint('⚠️ DataSource: Unexpected sessions data format, using mock data');
          return _getMockSessions(eventId);
        }
      } else {
        throw Exception("Failed to fetch sessions for event: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('❌ DataSource: Error fetching sessions - $e');
      // For demo purposes, return mock data instead of throwing
      return _getMockSessions(eventId);
    }
  }

  @override
  Future<String> markAttendance({
    required String participantId,
    required String sessionId,
    required String roomId,
  }) async {
    try {
      debugPrint(
        '🚀 DataSource: Marking attendance for participant $participantId',
      );

      final token = await userDataService.getAuthToken() ?? '';
      final response = await dioClient.post(
        "/attendance/mark",
        data: {
          'participant_id': participantId,
          'session_id': sessionId,
          'room_id': roomId,
          'timestamp': DateTime.now().toIso8601String(),
        },
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data is Map<String, dynamic>
            ? (data["message"] ?? "Attendance marked successfully")
            : "Attendance marked successfully";
      } else {
        throw Exception("Failed to mark attendance: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('❌ DataSource: Error marking attendance - $e');
      throw Exception("Failed to mark attendance: $e");
    }
  }

  // Mock data for demo purposes
  List<AttendanceEventModel> _getMockEvents() {
    return [
      AttendanceEventModel(
        id: '1',
        title: 'Tech Conference 2024',
        description: 'Annual technology conference with multiple sessions',
        location: 'San Francisco, CA',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 2)),
        isActive: true,
        banner: null,
        organizationId: '1',
        sessions: [
          AttendanceSession(
            id: '1',
            eventId: '1',
            title: 'Opening Ceremony',
            description: 'Welcome and introduction to the event',
            startTime: DateTime.now().add(const Duration(hours: 1)),
            endTime: DateTime.now().add(const Duration(hours: 2)),
            isActive: true,
            roomsCount: 3,
          ),
          AttendanceSession(
            id: '2',
            eventId: '1',
            title: 'Technical Workshop',
            description: 'Hands-on technical training session',
            startTime: DateTime.now().add(const Duration(hours: 3)),
            endTime: DateTime.now().add(const Duration(hours: 5)),
            isActive: true,
            roomsCount: 4,
          ),
          AttendanceSession(
            id: '3',
            eventId: '1',
            title: 'Panel Discussion',
            description: 'Industry experts discussing current trends',
            startTime: DateTime.now().add(const Duration(hours: 6)),
            endTime: DateTime.now().add(const Duration(hours: 7)),
            isActive: false,
            roomsCount: 2,
          ),
        ],
      ),
      AttendanceEventModel(
        id: '2',
        title: 'Workshop Series',
        description: 'Hands-on workshops for skill development',
        location: 'New York, NY',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 3)),
        isActive: false,
        banner: null,
        organizationId: '1',
        sessions: [
          AttendanceSession(
            id: '4',
            eventId: '2',
            title: 'Introduction to Python',
            description: 'Basic Python programming for beginners',
            startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
            endTime: DateTime.now().add(const Duration(days: 1, hours: 12)),
            isActive: true,
            roomsCount: 2,
          ),
          AttendanceSession(
            id: '5',
            eventId: '2',
            title: 'Advanced SQL',
            description: 'Database management and optimization',
            startTime: DateTime.now().add(const Duration(days: 2, hours: 9)),
            endTime: DateTime.now().add(const Duration(days: 2, hours: 11)),
            isActive: true,
            roomsCount: 3,
          ),
        ],
      ),
      AttendanceEventModel(
        id: '3',
        title: 'Networking Event',
        description: 'Professional networking and business connections',
        location: 'Austin, TX',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: false,
        banner: null,
        organizationId: '1',
        sessions: [
          AttendanceSession(
            id: '6',
            eventId: '3',
            title: 'Lunch Break',
            description: 'Time for participants to network and eat',
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
            isActive: false,
            roomsCount: 1,
          ),
        ],
      ),
    ];
  }

  List<AttendanceRoom> _getMockRooms(String sessionId) {
    return [
      AttendanceRoom(
        id: '1',
        sessionId: sessionId,
        name: 'Main Auditorium',
        description: 'Large auditorium for main presentations',
        capacity: 200,
        attendanceCount: 45,
        location: 'Building A, Floor 1',
      ),
      AttendanceRoom(
        id: '2',
        sessionId: sessionId,
        name: 'Workshop Room A',
        description: 'Interactive workshop space',
        capacity: 50,
        attendanceCount: 38,
        location: 'Building B, Floor 2',
      ),
      AttendanceRoom(
        id: '3',
        sessionId: sessionId,
        name: 'Workshop Room B',
        description: 'Secondary workshop space',
        capacity: 50,
        attendanceCount: 42,
        location: 'Building B, Floor 2',
      ),
      AttendanceRoom(
        id: '4',
        sessionId: sessionId,
        name: 'Meeting Room C',
        description: 'Small group discussions',
        capacity: 25,
        attendanceCount: 25,
        location: 'Building C, Floor 3',
      ),
    ];
  }

  List<AttendanceSession> _getMockSessions(String eventId) {
    return [
      AttendanceSession(
        id: '1',
        eventId: eventId,
        title: 'Opening Ceremony',
        description: 'Welcome and introduction to the event',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        isActive: true,
        roomsCount: 3,
      ),
      AttendanceSession(
        id: '2',
        eventId: eventId,
        title: 'Technical Workshop',
        description: 'Hands-on technical training session',
        startTime: DateTime.now().add(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        isActive: true,
        roomsCount: 4,
      ),
      AttendanceSession(
        id: '3',
        eventId: eventId,
        title: 'Panel Discussion',
        description: 'Industry experts discussing current trends',
        startTime: DateTime.now().add(const Duration(hours: 6)),
        endTime: DateTime.now().add(const Duration(hours: 7)),
        isActive: false,
        roomsCount: 2,
      ),
    ];
  }
}
