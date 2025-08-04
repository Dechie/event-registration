part of 'auth_event.dart';
abstract class ProfileEvent extends AuthEvent {}

class CreateProfileEvent extends ProfileEvent {
  final String fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String phoneNumber;
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

  CreateProfileEvent({
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    required this.phoneNumber,
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
  });
}

class UpdateProfileEvent extends ProfileEvent {
  final String fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String phoneNumber;
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

  UpdateProfileEvent({
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    required this.phoneNumber,
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
  });
}