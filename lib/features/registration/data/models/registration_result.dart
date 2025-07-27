
// lib/features/registration/data/models/registration_result.dart
import 'package:equatable/equatable.dart';
import 'package:event_reg/features/registration/data/models/participant.dart';

enum RegistrationResultStatus {
  success,
  verified,
  pending,
  failed,
}

class RegistrationResult extends Equatable {
  final RegistrationResultStatus status;
  final String message;
  final Participant? participant;
  final String? qrCodeUrl;
  final Map<String, dynamic>? additionalData;

  const RegistrationResult({
    required this.status,
    required this.message,
    this.participant,
    this.qrCodeUrl,
    this.additionalData,
  });

  factory RegistrationResult.fromJson(Map<String, dynamic> json) {
    return RegistrationResult(
      status: RegistrationResultStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RegistrationResultStatus.pending,
      ),
      message: json['message'] as String,
      participant: json['participant'] != null
          ? Participant.fromJson(json['participant'] as Map<String, dynamic>)
          : null,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'message': message,
      'participant': participant?.toJson(),
      'qrCodeUrl': qrCodeUrl,
      'additionalData': additionalData,
    };
  }

  bool get isSuccess => status == RegistrationResultStatus.success;
  bool get isVerified => status == RegistrationResultStatus.verified;
  bool get isPending => status == RegistrationResultStatus.pending;
  bool get isFailed => status == RegistrationResultStatus.failed;

  @override
  List<Object?> get props => [
        status,
        message,
        participant,
        qrCodeUrl,
        additionalData,
      ];
}
