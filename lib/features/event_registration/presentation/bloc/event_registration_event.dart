import 'package:equatable/equatable.dart';

// Events
abstract class EventRegistrationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAvailableEventsRequested extends EventRegistrationEvent {}

class FetchMyEventsRequested extends EventRegistrationEvent {}

class RegisterForEventRequested extends EventRegistrationEvent {
  final String eventId;

  RegisterForEventRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
