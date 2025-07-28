import 'package:equatable/equatable.dart';
import 'package:event_reg/core/shared/models/participant.dart';

class RegistrationResponse extends Equatable {
  final String id;
  final String message;
  final Participant participant;
  final bool requiresVerification;
  final String? verificationMethod; // 'email', 'sms', etc.
  final String? qrCode;

  const RegistrationResponse({
    required this.id,
    required this.message,
    required this.participant,
    this.requiresVerification = false,
    this.verificationMethod,
    this.qrCode,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      id: json['id'] as String,
      message: json['message'] as String,
      participant: Participant.fromJson(
        json['participant'] as Map<String, dynamic>,
      ),
      requiresVerification: json['requiresVerification'] as bool? ?? false,
      verificationMethod: json['verificationMethod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'participant': participant.toJson(),
      'requiresVerification': requiresVerification,
      'verificationMethod': verificationMethod,
    };
  }

  @override
  List<Object?> get props => [
    id,
    message,
    participant,
    requiresVerification,
    verificationMethod,
  ];
}
