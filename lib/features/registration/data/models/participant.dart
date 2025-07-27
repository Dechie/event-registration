import 'package:event_reg/features/dashboard/data/models/session.dart';

enum RegistrationStatus {
  pending,
  confirmed,
  cancelled,
  waitlisted,
}

enum AttendanceStatus {
  notCheckedIn,
  checkedIn,
  checkedOut,
  noShow,
}

class Participant {
  final String id;
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
  final String? photoUrl;
  final List<Session> selectedSessions; // Changed to List<Session>
  final DateTime createdAt;
  final RegistrationStatus registrationStatus;
  final AttendanceStatus attendanceStatus;
  final String? qrCodeId;
  final DateTime? lastUpdatedAt;

  const Participant({
    required this.id,
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
    this.photoUrl,
    this.selectedSessions = const [], // Default empty list
    required this.createdAt,
    this.registrationStatus = RegistrationStatus.pending,
    this.attendanceStatus = AttendanceStatus.notCheckedIn,
    this.qrCodeId,
    this.lastUpdatedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String,
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
      photoUrl: json['photoUrl'] as String?,
      selectedSessions: (json['selectedSessions'] as List<dynamic>?)
              ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [], // Parse list of Sessions
      createdAt: DateTime.parse(json['createdAt'] as String),
      registrationStatus: RegistrationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['registrationStatus'],
        orElse: () => RegistrationStatus.pending,
      ),
      attendanceStatus: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['attendanceStatus'],
        orElse: () => AttendanceStatus.notCheckedIn,
      ),
      qrCodeId: json['qrCodeId'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'photoUrl': photoUrl,
      'selectedSessions':
          selectedSessions.map((e) => e.toJson()).toList(), // Serialize list of Sessions
      'createdAt': createdAt.toIso8601String(),
      'registrationStatus': registrationStatus.toString().split('.').last,
      'attendanceStatus': attendanceStatus.toString().split('.').last,
      'qrCodeId': qrCodeId,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  Participant copyWith({
    String? id,
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
    String? photoUrl,
    List<Session>? selectedSessions,
    DateTime? createdAt,
    RegistrationStatus? registrationStatus,
    AttendanceStatus? attendanceStatus,
    String? qrCodeId,
    DateTime? lastUpdatedAt,
  }) {
    return Participant(
      id: id ?? this.id,
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
      photoUrl: photoUrl ?? this.photoUrl,
      selectedSessions: selectedSessions ?? this.selectedSessions,
      createdAt: createdAt ?? this.createdAt,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  // Helper methods
  bool get isConfirmed => registrationStatus == RegistrationStatus.confirmed;
  bool get isPending => registrationStatus == RegistrationStatus.pending;
  bool get isCancelled => registrationStatus == RegistrationStatus.cancelled;
  bool get isWaitlisted =>
      registrationStatus == RegistrationStatus.waitlisted;

  bool get hasCheckedIn =>
      attendanceStatus == AttendanceStatus.checkedIn ||
      attendanceStatus == AttendanceStatus.checkedOut;
  bool get isPresent => attendanceStatus == AttendanceStatus.checkedIn;
  bool get hasLeft => attendanceStatus == AttendanceStatus.checkedOut;
  bool get isNoShow => attendanceStatus == AttendanceStatus.noShow;

  int get sessionsCount => selectedSessions.length;

  String get fullAddress {
    final parts = [city, region].where((part) => part?.isNotEmpty == true);
    return parts.join(', ');
  }

  String get displayName => fullName;

  String get registrationStatusDisplay {
    switch (registrationStatus) {
      case RegistrationStatus.pending:
        return 'Pending';
      case RegistrationStatus.confirmed:
        return 'Confirmed';
      case RegistrationStatus.cancelled:
        return 'Cancelled';
      case RegistrationStatus.waitlisted:
        return 'Waitlisted';
    }
  }

  String get attendanceStatusDisplay {
    switch (attendanceStatus) {
      case AttendanceStatus.notCheckedIn:
        return 'Not Checked In';
      case AttendanceStatus.checkedIn:
        return 'Checked In';
      case AttendanceStatus.checkedOut:
        return 'Checked Out';
      case AttendanceStatus.noShow:
        return 'No Show';
    }
  }
}