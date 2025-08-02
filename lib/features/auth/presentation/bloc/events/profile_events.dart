part of 'auth_event.dart';

class UpdateProfileEvent extends AuthEvent {
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

  const UpdateProfileEvent({
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

  @override
  List<Object?> get props => [
    fullName,
    gender,
    dateOfBirth,
    nationality,
    phoneNumber,
    region,
    city,
    woreda,
    idNumber,
    occupation,
    organization,
    department,
    industry,
    yearsOfExperience,
    photoPath,
  ];
}


class CreateProfileEvent extends AuthEvent {
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

  const CreateProfileEvent({
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

  @override
  List<Object?> get props => [
    fullName,
    gender,
    dateOfBirth,
    nationality,
    phoneNumber,
    region,
    city,
    woreda,
    idNumber,
    occupation,
    organization,
    department,
    industry,
    yearsOfExperience,
    photoPath,
  ];
}
