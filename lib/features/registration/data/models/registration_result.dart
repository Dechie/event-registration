import 'package:event_reg/features/registration/data/models/participant.dart';

class RegistrationResult {
  final Participant participant;
  final String qrCode;

  const RegistrationResult({required this.participant, required this.qrCode});
}
