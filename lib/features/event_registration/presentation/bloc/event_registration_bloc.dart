import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/event_registration/data/datasource/event_registration_datasource.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_event.dart';
import 'package:event_reg/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/event_reg_request.dart';
import 'event_registration_state.dart';

class EventRegistrationBloc
    extends Bloc<EventRegistrationEvent, EventRegistrationState> {
  final EventRegistrationDataSource dataSource;
  final UserDataService userDataService;

  EventRegistrationBloc({
    required this.dataSource,
    required this.userDataService,
  }) : super(EventRegistrationInitial()) {
    on<FetchAvailableEventsRequested>(_onFetchAvailableEvents);
    on<RegisterForEventRequested>(_onRegisterForEvent);
    on<FetchMyEventsRequested>(_onFetchMyEvents);
    on<FetchMyRegistrationsRequested>(_onFetchMyRegistrations);
    on<CheckRegistrationStatusRequested>(_onCheckRegistrationStatus);
    on<GenerateBadgeRequested>(_onGenerateBadge);
    on<FetchBadgeRequested>(_onFetchBadge);
  }

  Future<void> _onCheckRegistrationStatus(
    CheckRegistrationStatusRequested event,
    Emitter<EventRegistrationState> emit,
  ) async {
    emit(EventRegistrationLoading());

    try {
      final registration = await dataSource.getRegistrationStatus(
        event.eventId,
      );
      emit(RegistrationStatusLoaded(registration: registration));
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
    }
  }

  Future<void> _onFetchAvailableEvents(
    FetchAvailableEventsRequested event,
    Emitter<EventRegistrationState> emit,
  ) async {
    emit(EventRegistrationLoading());

    try {
      final events = await dataSource.fetchAvailableEvents();
      emit(AvailableEventsLoaded(events: events));
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
    }
  }

  Future<void> _onFetchBadge(
    FetchBadgeRequested event,
    Emitter<EventRegistrationState> emit,
  ) async {
    emit(EventRegistrationLoading());

    try {
      final badge = await dataSource.getBadge(event.eventId);
      if (badge != null) {
        emit(BadgeLoaded(badge: badge));
      } else {
        emit(BadgeNotFound(message: 'Badge not found or not yet generated'));
      }
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
    }
  }

  Future<void> _onFetchMyEvents(
    FetchMyEventsRequested event,
    Emitter<EventRegistrationState> emit,
  ) async {
    emit(EventRegistrationLoading());

    try {
      final events = await dataSource.getMyRegisteredEvents();
      emit(MyEventsLoaded(events: events));
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
    }
  }

  Future<void> _onFetchMyRegistrations(
    FetchMyRegistrationsRequested event,
    Emitter<EventRegistrationState> emit,
  ) async {
    emit(EventRegistrationLoading());

    try {
      final registrations = await dataSource.getMyRegistrations();
      emit(MyRegistrationsLoaded(registrations: registrations));
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
    }
  }

  Future<void> _onGenerateBadge(
    GenerateBadgeRequested event,
    Emitter<EventRegistrationState> emit,
  ) async {
    emit(EventRegistrationLoading());

    try {
      await dataSource.generateBadge(event.eventId);
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
    }
  }

  Future<void> _onRegisterForEvent(
    RegisterForEventRequested event,
    Emitter<EventRegistrationState> emit,
  ) async {
    emit(EventRegistrationLoading());

    try {

    final userDataService = sl<UserDataService>();
      final user = await userDataService.getCachedUser();
      if (user == null) {
        emit(EventRegistrationError(message: 'User not authenticated'));

        return;
      }

      final participant = user;
      // if (participant.fullName == null) {
      //   emit(EventRegistrationError(message: 'Participant profile not found'));
      //   return;
      // }

      final request = EventRegistrationRequest(
        eventId: event.eventId,
      );

      final response = await dataSource.registerForEvent(
        request,
        event.eventId,
      );
      emit(EventRegistrationSuccess(registration: response));
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
    }
  }
}
