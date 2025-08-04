import 'package:equatable/equatable.dart';

import '../../../landing/data/models/event.dart';
import '../../data/models/event_reg_response.dart';

abstract class EventRegistrationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventRegistrationInitial extends EventRegistrationState {}

class EventRegistrationLoading extends EventRegistrationState {}

class AvailableEventsLoaded extends EventRegistrationState {
  final List<Event> events;
  
  AvailableEventsLoaded({required this.events});
  
  @override
  List<Object?> get props => [events];
}

class EventRegistrationSuccess extends EventRegistrationState {
  final EventRegistrationResponse registration;
  
  EventRegistrationSuccess({required this.registration});
  
  @override
  List<Object?> get props => [registration];
}

class MyEventsLoaded extends EventRegistrationState {
  final List<Event> events;
  
  MyEventsLoaded({required this.events});
  
  @override
  List<Object?> get props => [events];
}

class EventRegistrationError extends EventRegistrationState {
  final String message;
  
  EventRegistrationError({required this.message});
  
  @override
  List<Object?> get props => [message];
}