// lib/features/dashboard/data/datasource/dashboard_remote_datasource.dart
// import 'package:dio/dio.dart';
// import 'package:event_reg/core/error/exceptions.dart';
// import 'package:event_reg/core/network/dio_client.dart';
// import 'package:event_reg/features/dashboard/data/models/dashboard_stats.dart';
// import 'package:event_reg/features/dashboard/data/models/event.dart';
// import 'package:event_reg/features/dashboard/data/models/participant_dashboard.dart';
// import 'package:event_reg/features/dashboard/data/models/session.dart';

// abstract class DashboardRemoteDataSource {
//   Future<bool> checkInParticipant(String participantId, String? qrCode);
//   Future<void> checkOutParticipant(String participantId);
//   Future<Session> createSession(Map<String, dynamic> data);
//   Future<void> deleteSession(String sessionId);
//   // Admin Dashboard Methods
//   Future<DashboardStats> getAdminDashboardStats();
//   Future<List<Participant>> getAllParticipants({
//     int page = 1,
//     int limit = 20,
//     String? search,
//     RegistrationStatus? status,
//     AttendanceStatus? attendanceStatus,
//     String? searchQuery,
//     String? sessionFilter,
//     String? statusFilter,
//   });
//   Future<List<Session>> getAllSessions();
//   Future<Map<String, dynamic>> getAttendanceAnalytics();

//   Future<Map<String, dynamic>> getAttendanceReport();
//   Future<DashboardStats> getDashboardStats();
//   Future<Event> getEventDetails();

//   Future<List<Session>> getEventSessions();
//   // Participant Dashboard Methods
//   Future<ParticipantDashboard> getParticipantDashboard(String participantId);
//   Future<Participant> getParticipantProfile(String participantId);

//   Future<List<Session>> getParticipantSessions(String participantId);
//   Future<List<Participant>> getRecentParticipants({int limit = 10});
//   Future<Map<String, dynamic>> getRegistrationReport();
//   Future<Participant> updateAttendanceStatus(
//     String participantId,
//     AttendanceStatus status,
//   );
//   Future<bool> updateParticipantInfo(
//     String participantId,
//     Map<String, dynamic> updateData,
//   );

//   // Participant Management
//   Future<Participant> updateParticipantStatus(
//     String participantId,
//     RegistrationStatus status,
//   );
//   // Session Management
//   Future<Session> updateSession(String sessionId, Map<String, dynamic> data);
// }

// class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
//   final DioClient dioClient;

//   DashboardRemoteDataSourceImpl({required this.dioClient});
//   @override
//   Future<bool> checkInParticipant(String participantId, String? qrCode) async {
//     try {
//       final data = <String, dynamic>{'attendance_status': 'checkedIn'};

//       if (qrCode != null) {
//         data['qr_code'] = qrCode;
//       } else {}

//       final response = await dioClient.post(
//         '/admin/participants/$participantId/checkin',
//         data: data,
//       );

//       if (response.statusCode != 200) {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to check in participant',
//           code: 'CHECK_IN_ERROR',
//         );
//       }
//       return true;
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'CHECK_IN_ERROR');
//     }
//   }

//   @override
//   Future<void> checkOutParticipant(String participantId) async {
//     try {
//       final response = await dioClient.post(
//         '/admin/participants/$participantId/checkout',
//         data: {'attendance_status': 'checkedOut'},
//       );

//       if (response.statusCode != 200) {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to check out participant',
//           code: 'CHECK_OUT_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'CHECK_OUT_ERROR');
//     }
//   }

//   @override
//   Future<Session> createSession(Map<String, dynamic> data) async {
//     try {
//       final response = await dioClient.post('/admin/sessions', data: data);

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return Session.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to create session',
//           code: 'CREATE_SESSION_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'CREATE_SESSION_ERROR');
//     }
//   }

//   @override
//   Future<void> deleteSession(String sessionId) async {
//     try {
//       final response = await dioClient.delete('/admin/sessions/$sessionId');

//       if (response.statusCode != 200 && response.statusCode != 204) {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to delete session',
//           code: 'DELETE_SESSION_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'DELETE_SESSION_ERROR');
//     }
//   }

//   @override
//   Future<DashboardStats> getAdminDashboardStats() async {
//     try {
//       final response = await dioClient.get('/admin/dashboard/stats');

//       if (response.statusCode == 200) {
//         return DashboardStats.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to get dashboard stats',
//           code: 'DASHBOARD_STATS_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'DASHBOARD_STATS_ERROR');
//     }
//   }

//   @override
//   Future<List<Participant>> getAllParticipants({
//     int page = 1,
//     int limit = 20,
//     String? search,
//     RegistrationStatus? status,
//     AttendanceStatus? attendanceStatus,
//     String? searchQuery,
//     String? sessionFilter,
//     String? statusFilter,
//   }) async {
//     return [
//       Participant(
//         id: "id",
//         fullName: "fullName",
//         email: "email",
//         phoneNumber: "phoneNumber",
//         occupation: "occupation",
//         organization: "organization",
//         industry: "industry",
//         createdAt: DateTime.now(),
//       ),
//       Participant(
//         id: "id",
//         fullName: "fullName",
//         email: "email",
//         phoneNumber: "phoneNumber",
//         occupation: "occupation",
//         organization: "organization",
//         industry: "industry",
//         createdAt: DateTime.now(),
//       ),
//       Participant(
//         id: "id",
//         fullName: "fullName",
//         email: "email",
//         phoneNumber: "phoneNumber",
//         occupation: "occupation",
//         organization: "organization",
//         industry: "industry",
//         createdAt: DateTime.now(),
//       ),
//       Participant(
//         id: "id",
//         fullName: "fullName",
//         email: "email",
//         phoneNumber: "phoneNumber",
//         occupation: "occupation",
//         organization: "organization",
//         industry: "industry",
//         createdAt: DateTime.now(),
//       ),
//     ];
//     // try {
//     //       final queryParams = <String, dynamic>{'page': page, 'limit': limit};

//     //       if (search != null && search.isNotEmpty) {
//     //         queryParams['search'] = search;
//     //       }
//     //       if (status != null) {
//     //         queryParams['registration_status'] = status.toString().split('.').last;
//     //       }
//     //       if (attendanceStatus != null) {
//     //         queryParams['attendance_status'] = attendanceStatus
//     //             .toString()
//     //             .split('.')
//     //             .last;
//     //       }

//     //       final response = await dioClient.get(
//     //         '/admin/participants',
//     //         queryParameters: queryParams,
//     //       );

//     //       if (response.statusCode == 200) {
//     //         final List<dynamic> participantsJson = response.data['data'] ?? [];
//     //         return participantsJson
//     //             .map((json) => Participant.fromJson(json))
//     //             .toList();
//     //       } else {
//     //         throw ServerException(
//     //           message: response.data['message'] ?? 'Failed to get participants',
//     //           code: 'GET_PARTICIPANTS_ERROR',
//     //         );
//     //       }
//     //     } on DioException catch (e) {
//     //       throw _handleDioException(e, 'GET_PARTICIPANTS_ERROR');
//     //     }
//   }

//   @override
//   Future<List<Session>> getAllSessions() async {
//     return <Session>[
//       Session(
//         id: "1",
//         title: "title",
//         description: "description",
//         startTime: DateTime.now(),
//         endTime: DateTime.now(),
//         location: "location",
//         capacity: 100,
//         currentAttendees: 50,
//         status: "active",
//       ),
//       Session(
//         id: "1",
//         title: "title",
//         description: "description",
//         startTime: DateTime.now(),
//         endTime: DateTime.now(),
//         location: "location",
//         capacity: 100,
//         currentAttendees: 50,
//         status: "active",
//       ),
//       Session(
//         id: "1",
//         title: "title",
//         description: "description",
//         startTime: DateTime.now(),
//         endTime: DateTime.now(),
//         location: "location",
//         capacity: 100,
//         currentAttendees: 50,
//         status: "active",
//       ),
//       Session(
//         id: "1",
//         title: "title",
//         description: "description",
//         startTime: DateTime.now(),
//         endTime: DateTime.now(),
//         location: "location",
//         capacity: 100,
//         currentAttendees: 50,
//         status: "active",
//       ),
//     ];
//   }

//   @override
//   Future<Map<String, dynamic>> getAttendanceAnalytics() async {
//     return {"key1": "value1", "key2": "value2"};
//   }

//   @override
//   Future<Map<String, dynamic>> getAttendanceReport() async {
//     try {
//       final response = await dioClient.get('/admin/reports/attendance');

//       if (response.statusCode == 200) {
//         return response.data['data'] as Map<String, dynamic>;
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to get attendance report',
//           code: 'ATTENDANCE_REPORT_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'ATTENDANCE_REPORT_ERROR');
//     }
//   }

//   @override
//   Future<DashboardStats> getDashboardStats() async {
//     return DashboardStats(
//       totalRegistrants: 100,
//       checkedInAttendees: 80,
//       noShows: 20,
//       sessionAttendance: {"key1": 10},
//       lastUpdated: DateTime.now(),
//     );
//   }

//   @override
//   Future<Event> getEventDetails() async {
//     try {
//       final response = await dioClient.get('/admin/event');

//       if (response.statusCode == 200) {
//         return Event.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to get event details',
//           code: 'EVENT_DETAILS_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'EVENT_DETAILS_ERROR');
//     }
//   }

//   @override
//   Future<List<Session>> getEventSessions() async {
//     try {
//       final response = await dioClient.get('/admin/sessions');

//       if (response.statusCode == 200) {
//         final List<dynamic> sessionsJson = response.data['data'] ?? [];
//         return sessionsJson.map((json) => Session.fromJson(json)).toList();
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to get event sessions',
//           code: 'EVENT_SESSIONS_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'EVENT_SESSIONS_ERROR');
//     }
//   }

//   @override
//   Future<ParticipantDashboard> getParticipantDashboard(
//     String participantId,
//   ) async {
//     try {
//       final response = await dioClient.get(
//         '/participant/dashboard/$participantId',
//       );

//       if (response.statusCode == 200) {
//         return ParticipantDashboard.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to get participant dashboard',
//           code: 'PARTICIPANT_DASHBOARD_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'PARTICIPANT_DASHBOARD_ERROR');
//     }
//   }

//   @override
//   Future<Participant> getParticipantProfile(String participantId) async {
//     try {
//       final response = await dioClient.get(
//         '/participant/profile/$participantId',
//       );

//       if (response.statusCode == 200) {
//         return Participant.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to get participant profile',
//           code: 'PARTICIPANT_PROFILE_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'PARTICIPANT_PROFILE_ERROR');
//     }
//   }

//   @override
//   Future<List<Session>> getParticipantSessions(String participantId) async {
//     try {
//       final response = await dioClient.get(
//         '/participant/sessions/$participantId',
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> sessionsJson = response.data['data'] ?? [];
//         return sessionsJson.map((json) => Session.fromJson(json)).toList();
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to get participant sessions',
//           code: 'PARTICIPANT_SESSIONS_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'PARTICIPANT_SESSIONS_ERROR');
//     }
//   }

//   @override
//   Future<List<Participant>> getRecentParticipants({int limit = 10}) async {
//     try {
//       final response = await dioClient.get(
//         '/admin/participants/recent',
//         queryParameters: {'limit': limit},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> participantsJson = response.data['data'] ?? [];
//         return participantsJson
//             .map((json) => Participant.fromJson(json))
//             .toList();
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to get recent participants',
//           code: 'RECENT_PARTICIPANTS_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'RECENT_PARTICIPANTS_ERROR');
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> getRegistrationReport() async {
//     try {
//       final response = await dioClient.get('/admin/reports/registration');

//       if (response.statusCode == 200) {
//         return response.data['data'] as Map<String, dynamic>;
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to get registration report',
//           code: 'REGISTRATION_REPORT_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'REGISTRATION_REPORT_ERROR');
//     }
//   }

//   @override
//   Future<Participant> updateAttendanceStatus(
//     String participantId,
//     AttendanceStatus status,
//   ) async {
//     try {
//       final response = await dioClient.put(
//         '/admin/participants/$participantId/attendance',
//         data: {'attendance_status': status.toString().split('.').last},
//       );

//       if (response.statusCode == 200) {
//         return Participant.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to update attendance status',
//           code: 'UPDATE_ATTENDANCE_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'UPDATE_ATTENDANCE_ERROR');
//     }
//   }

//   @override
//   Future<bool> updateParticipantInfo(
//     String participantId,
//     Map<String, dynamic> updateData,
//   ) async {
//     return false;
//   }

//   @override
//   Future<Participant> updateParticipantStatus(
//     String participantId,
//     RegistrationStatus status,
//   ) async {
//     try {
//       final response = await dioClient.put(
//         '/admin/participants/$participantId/status',
//         data: {'registration_status': status.toString().split('.').last},
//       );

//       if (response.statusCode == 200) {
//         return Participant.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message:
//               response.data['message'] ?? 'Failed to update participant status',
//           code: 'UPDATE_PARTICIPANT_STATUS_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'UPDATE_PARTICIPANT_STATUS_ERROR');
//     }
//   }

//   @override
//   Future<Session> updateSession(
//     String sessionId,
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       final response = await dioClient.put(
//         '/admin/sessions/$sessionId',
//         data: data,
//       );

//       if (response.statusCode == 200) {
//         return Session.fromJson(response.data['data']);
//       } else {
//         throw ServerException(
//           message: response.data['message'] ?? 'Failed to update session',
//           code: 'UPDATE_SESSION_ERROR',
//         );
//       }
//     } on DioException catch (e) {
//       throw _handleDioException(e, 'UPDATE_SESSION_ERROR');
//     }
//   }

//   // Helper method to handle DioExceptions consistently
//   AppException _handleDioException(DioException e, String defaultCode) {
//     if (e.type == DioExceptionType.connectionTimeout ||
//         e.type == DioExceptionType.receiveTimeout ||
//         e.type == DioExceptionType.sendTimeout) {
//       return NetworkException(
//         message: 'Connection timeout. Please check your internet connection.',
//         code: 'TIMEOUT_ERROR',
//       );
//     } else if (e.type == DioExceptionType.connectionError) {
//       return NetworkException(
//         message: 'No internet connection. Please check your network.',
//         code: 'NETWORK_ERROR',
//       );
//     } else if (e.response != null) {
//       final statusCode = e.response!.statusCode;
//       final responseData = e.response!.data;

//       switch (statusCode) {
//         case 400:
//           return ServerException(
//             message: responseData['message'] ?? 'Bad request',
//             code: 'BAD_REQUEST',
//           );
//         case 401:
//           return AuthenticationException(
//             message: responseData['message'] ?? 'Authentication required',
//             code: 'AUTHENTICATION_ERROR',
//           );
//         case 403:
//           return AuthorizationException(
//             message: responseData['message'] ?? 'Access denied',
//             code: 'AUTHORIZATION_ERROR',
//           );
//         case 404:
//           return ServerException(
//             message: responseData['message'] ?? 'Resource not found',
//             code: 'NOT_FOUND',
//           );
//         case 422:
//           final errors = responseData['errors'] as Map<String, dynamic>?;
//           return ValidationException(
//             message: responseData['message'] ?? 'Validation failed',
//             code: 'VALIDATION_ERROR',
//             errors: errors?.map(
//               (key, value) => MapEntry(key, List<String>.from(value)),
//             ),
//           );
//         case 429:
//           return ServerException(
//             message: responseData['message'] ?? 'Too many requests',
//             code: 'RATE_LIMIT_ERROR',
//           );
//         case 500:
//           return ServerException(
//             message: responseData['message'] ?? 'Internal server error',
//             code: 'SERVER_ERROR',
//           );
//         default:
//           return ServerException(
//             message: responseData['message'] ?? 'Server error occurred',
//             code: defaultCode,
//           );
//       }
//     } else {
//       return ServerException(
//         message: 'Unknown server error occurred',
//         code: defaultCode,
//       );
//     }
//   }
// }
