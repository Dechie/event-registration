import 'package:event_reg/features/registration/data/models/participant.dart';

abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class OTPSentState extends RegistrationState {
  final String email;

  OTPSentState({required this.email});
}

class OTPVerifiedState extends RegistrationState {}

class RegistrationSuccessState extends RegistrationState {
  final Participant participant;
  final String qrCode;

  RegistrationSuccessState({required this.participant, required this.qrCode});
}

class RegistrationErrorState extends RegistrationState {
  final String message;

  RegistrationErrorState({required this.message});
}
