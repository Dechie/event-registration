class RegisterParticipantEvent extends RegistrationEvent {
  final String fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String phoneNumber;
  final String email;
  final String? region;
  final String? city;
  final String? woreda;
  final String? idNumber;
  final String occupation;
  final String organization;
  final String? department;
  final String industry;
  final int? yearsOfExperience;
  final String? photoPath;
  final List<String> selectedSessions;

  RegisterParticipantEvent({
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    required this.phoneNumber,
    required this.email,
    this.region,
    this.city,
    this.woreda,
    this.idNumber,
    required this.occupation,
    required this.organization,
    this.department,
    required this.industry,
    this.yearsOfExperience,
    this.photoPath,
    required this.selectedSessions,
  });
}

abstract class RegistrationEvent {}

class ResetRegistrationEvent extends RegistrationEvent {}

class SendOTPEvent extends RegistrationEvent {
  final String email;

  SendOTPEvent({required this.email});
}

class VerifyOTPEvent extends RegistrationEvent {
  final String email;
  final String otp;

  VerifyOTPEvent({required this.email, required this.otp});
}
