// lib/features/event_registration/presentation/bloc/event_registration_state.dart
import 'package:equatable/equatable.dart';

import '../../../landing/data/models/event.dart';
import '../../data/models/event_reg_response.dart';
import '../../data/models/event_registration.dart';
import '../../data/models/participant_badge.dart';

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

class MyRegistrationsLoaded extends EventRegistrationState {
  final List<EventRegistration> registrations;
  
  MyRegistrationsLoaded({required this.registrations});
  
  @override
  List<Object?> get props => [registrations];
}

class RegistrationStatusLoaded extends EventRegistrationState {
  final EventRegistration registration;
  
  RegistrationStatusLoaded({required this.registration});
  
  @override
  List<Object?> get props => [registration];
}

class BadgeGenerated extends EventRegistrationState {
  final ParticipantBadge badge;
  
  BadgeGenerated({required this.badge});
  
  @override
  List<Object?> get props => [badge];
}

class BadgeLoaded extends EventRegistrationState {
  final ParticipantBadge badge;
  
  BadgeLoaded({required this.badge});
  
  @override
  List<Object?> get props => [badge];
}

class BadgeNotFound extends EventRegistrationState {
  final String message;
  
  BadgeNotFound({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class EventRegistrationError extends EventRegistrationState {
  final String message;
  
  EventRegistrationError({required this.message});
  
  @override
  List<Object?> get props => [message];
}