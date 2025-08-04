// lib/features/event_registration/presentation/bloc/event_registration_event.dart
import 'package:equatable/equatable.dart';
import 'package:event_reg/features/event_registration/data/models/participant_badge.dart';

// Events
abstract class EventRegistrationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAvailableEventsRequested extends EventRegistrationEvent {}

class FetchMyEventsRequested extends EventRegistrationEvent {}

class FetchMyRegistrationsRequested extends EventRegistrationEvent {}

class RegisterForEventRequested extends EventRegistrationEvent {
  final String eventId;

  RegisterForEventRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class CheckRegistrationStatusRequested extends EventRegistrationEvent {
  final String eventId;

  CheckRegistrationStatusRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class GenerateBadgeRequested extends EventRegistrationEvent {
  final String eventId;
  final ParticipantBadge badge;

  GenerateBadgeRequested({required this.eventId, required this.badge});

  @override
  List<Object?> get props => [eventId, badge];
}

class FetchBadgeRequested extends EventRegistrationEvent {
  final String eventId;
  final ParticipantBadge badge;

  FetchBadgeRequested({required this.eventId, required this.badge});

  @override
  List<Object?> get props => [eventId, badge];
}
