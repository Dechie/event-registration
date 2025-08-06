// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../data/repositories/dashboard_repository.dart';
// import 'dashboard_event.dart';
// import 'dashboard_state.dart';

// class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
//   final DashboardRepository repository;

//   DashboardBloc({required this.repository}) : super(DashboardInitial()) {
//     // Admin Dashboard Events
//     on<LoadDashboardStatsEvent>(_onLoadDashboardStats);
//     on<LoadParticipantsEvent>(_onLoadParticipants);
//     on<CheckInParticipantEvent>(_onCheckInParticipant);
//     on<CheckOutParticipantEvent>(_onCheckOutParticipant);
//     on<LoadSessionsEvent>(_onLoadSessions);
//     on<LoadAttendanceAnalyticsEvent>(_onLoadAttendanceAnalytics);

//     // Participant Dashboard Events
//     on<LoadParticipantDashboardEvent>(_onLoadParticipantDashboard);
//     on<UpdateParticipantInfoEvent>(_onUpdateParticipantInfo);
//     on<DownloadConfirmationPdfEvent>(_onDownloadConfirmationPdf);

//     // Utility Events
//     on<ClearDashboardCacheEvent>(_onClearDashboardCache);
//     on<RefreshDashboardEvent>(_onRefreshDashboard);
//   }

//   Future<void> _onCheckInParticipant(
//     CheckInParticipantEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     try {
//       final success = await repository.checkInParticipant(event.participantId);
//       emit(
//         ParticipantCheckedIn(
//           participantId: event.participantId,
//           success: success,
//         ),
//       );

//       // Refresh participants list after check-in
//       add(LoadParticipantsEvent());
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onCheckOutParticipant(
//     CheckOutParticipantEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     try {
//       final success = await repository.checkOutParticipant(event.participantId);
//       emit(
//         ParticipantCheckedIn(
//           participantId: event.participantId,
//           success: success,
//         ),
//       );

//       // Refresh participants list after check-out
//       add(LoadParticipantsEvent());
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onClearDashboardCache(
//     ClearDashboardCacheEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     try {
//       await repository.clearCache();
//       emit(DashboardCacheCleared());
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onDownloadConfirmationPdf(
//     DownloadConfirmationPdfEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     emit(DashboardLoading());

//     try {
//       final downloadUrl = await repository.downloadConfirmationPdf(
//         event.participantId,
//       );
//       emit(ConfirmationPdfReady(downloadUrl: downloadUrl));
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onLoadAttendanceAnalytics(
//     LoadAttendanceAnalyticsEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     emit(DashboardLoading());

//     try {
//       final analytics = await repository.getAttendanceAnalytics();
//       emit(AttendanceAnalyticsLoaded(analytics: analytics));
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onLoadDashboardStats(
//     LoadDashboardStatsEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     emit(DashboardLoading());

//     try {
//       final stats = await repository.getDashboardStats();
//       emit(DashboardStatsLoaded(stats: stats));
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onLoadParticipantDashboard(
//     LoadParticipantDashboardEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     emit(DashboardLoading());

//     try {
//       final dashboard = await repository.getParticipantDashboard(event.email);
//       emit(ParticipantDashboardLoaded(dashboard: dashboard));
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onLoadParticipants(
//     LoadParticipantsEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     emit(DashboardLoading());

//     try {
//       final participants = await repository.getAllParticipants(
//         searchQuery: event.searchQuery,
//         sessionFilter: event.sessionFilter,
//         statusFilter: event.statusFilter,
//       );

//       emit(
//         ParticipantsLoaded(
//           participants: participants,
//           searchQuery: event.searchQuery,
//           sessionFilter: event.sessionFilter,
//           statusFilter: event.statusFilter,
//         ),
//       );
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onLoadSessions(
//     LoadSessionsEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     emit(DashboardLoading());

//     try {
//       final sessions = await repository.getAllSessions();
//       emit(SessionsLoaded(sessions: sessions));
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }

//   Future<void> _onRefreshDashboard(
//     RefreshDashboardEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     // Clear cache and reload data
//     await repository.clearCache();
//     add(LoadDashboardStatsEvent());
//   }

//   Future<void> _onUpdateParticipantInfo(
//     UpdateParticipantInfoEvent event,
//     Emitter<DashboardState> emit,
//   ) async {
//     emit(DashboardLoading());

//     try {
//       final success = await repository.updateParticipantInfo(
//         event.participantId,
//         event.updateData,
//       );
//       emit(ParticipantInfoUpdated(success: success));
//     } catch (e) {
//       emit(DashboardError(message: e.toString()));
//     }
//   }
// }
