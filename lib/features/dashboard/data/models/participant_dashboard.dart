import 'package:event_reg/features/dashboard/data/models/event.dart';
import 'package:event_reg/features/registration/data/models/participant.dart';

class ParticipantDashboard {
  final Participant participant;
  final String qrCode;
  final String confirmationStatus;
  final List<String> selectedSessions;
  final Event eventInfo;
  final bool canEditInfo;

  const ParticipantDashboard({
    required this.participant,
    required this.qrCode,
    required this.confirmationStatus,
    required this.selectedSessions,
    required this.eventInfo,
    required this.canEditInfo,
  });

  factory ParticipantDashboard.fromJson(Map<String, dynamic> json) {
    return ParticipantDashboard(
      participant: Participant.fromJson(
        json['participant'] as Map<String, dynamic>,
      ),
      qrCode: json['qrCode'] as String,
      confirmationStatus: json['confirmationStatus'] as String,
      selectedSessions: List<String>.from(json['selectedSessions'] as List),
      eventInfo: Event.fromJson(json['eventInfo'] as Map<String, dynamic>),
      canEditInfo: json['canEditInfo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant.toJson(),
      'qrCode': qrCode,
      'confirmationStatus': confirmationStatus,
      'selectedSessions': selectedSessions,
      'eventInfo': eventInfo.toJson(),
      'canEditInfo': canEditInfo,
    };
  }
}
