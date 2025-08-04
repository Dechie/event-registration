import 'package:equatable/equatable.dart';

class CheckRegistrationStatusRequested extends EventRegistrationEvent {
  final String eventId;

  CheckRegistrationStatusRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

// Events
abstract class EventRegistrationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAvailableEventsRequested extends EventRegistrationEvent {}

class FetchBadgeRequested extends EventRegistrationEvent {
  final String eventId;

  FetchBadgeRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class FetchMyEventsRequested extends EventRegistrationEvent {}

class FetchMyRegistrationsRequested extends EventRegistrationEvent {}

class GenerateBadgeRequested extends EventRegistrationEvent {
  final String eventId;

  GenerateBadgeRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class RegisterForEventRequested extends EventRegistrationEvent {
  final String eventId;

  RegisterForEventRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
