// lib/features/registration/data/models/registration_request.dart
import 'package:equatable/equatable.dart';
import 'package:event_reg/features/dashboard/data/models/session.dart';

class RegistrationRequest extends Equatable {
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
  final List<String> selectedSessionIds;
  final Map<String, dynamic>? customFields;

  const RegistrationRequest({
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
    this.selectedSessionIds = const [],
    this.customFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'phoneNumber': phoneNumber,
      'email': email,
      'region': region,
      'city': city,
      'woreda': woreda,
      'idNumber': idNumber,
      'occupation': occupation,
      'organization': organization,
      'department': department,
      'industry': industry,
      'yearsOfExperience': yearsOfExperience,
      'selectedSessionIds': selectedSessionIds,
      'customFields': customFields,
    };
  }

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) {
    return RegistrationRequest(
      fullName: json['fullName'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      nationality: json['nationality'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      region: json['region'] as String?,
      city: json['city'] as String?,
      woreda: json['woreda'] as String?,
      idNumber: json['idNumber'] as String?,
      occupation: json['occupation'] as String,
      organization: json['organization'] as String,
      department: json['department'] as String?,
      industry: json['industry'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      selectedSessionIds: (json['selectedSessionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }

  RegistrationRequest copyWith({
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? nationality,
    String? phoneNumber,
    String? email,
    String? region,
    String? city,
    String? woreda,
    String? idNumber,
    String? occupation,
    String? organization,
    String? department,
    String? industry,
    int? yearsOfExperience,
    List<String>? selectedSessionIds,
    Map<String, dynamic>? customFields,
  }) {
    return RegistrationRequest(
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      region: region ?? this.region,
      city: city ?? this.city,
      woreda: woreda ?? this.woreda,
      idNumber: idNumber ?? this.idNumber,
      occupation: occupation ?? this.occupation,
      organization: organization ?? this.organization,
      department: department ?? this.department,
      industry: industry ?? this.industry,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      selectedSessionIds: selectedSessionIds ?? this.selectedSessionIds,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        gender,
        dateOfBirth,
        nationality,
        phoneNumber,
        email,
        region,
        city,
        woreda,
        idNumber,
        occupation,
        organization,
        department,
        industry,
        yearsOfExperience,
        selectedSessionIds,
        customFields,
      ];
}
