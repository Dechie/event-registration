// lib/features/registration/data/models/participant.dart
import 'package:event_reg/core/shared/models/user.dart';
import 'package:event_reg/features/dashboard/data/models/session.dart';

enum AttendanceStatus { notCheckedIn, checkedIn, checkedOut, noShow }

class Participant extends BaseUser {
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? region;
  final String? city;
  final String? woreda;
  final String? idNumber;
  final String occupation;
  final String organization;
  final String? department;
  final String industry;
  final int? yearsOfExperience;
  final List<Session> selectedSessions;
  final RegistrationStatus registrationStatus;
  final AttendanceStatus attendanceStatus;
  final String? qrCodeId;
  final String? photoUrl;
  final DateTime? lastUpdatedAt;
  final Map<String, dynamic>? customFields;

  const Participant({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.region,
    this.city,
    this.woreda,
    this.idNumber,
    required this.occupation,
    required this.organization,
    this.department,
    required this.industry,
    this.yearsOfExperience,
    this.selectedSessions = const [],
    required super.createdAt,
    this.registrationStatus = RegistrationStatus.pending,
    this.attendanceStatus = AttendanceStatus.notCheckedIn,
    this.qrCodeId,
    this.photoUrl,
    this.lastUpdatedAt,
    this.customFields,
    super.status,
    super.lastLoginAt,
    super.profilePhotoUrl,
  }) : super(userType: UserType.participant);

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      nationality: json['nationality'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      woreda: json['woreda'] as String?,
      idNumber: json['idNumber'] as String?,
      occupation: json['occupation'] as String,
      organization: json['organization'] as String,
      department: json['department'] as String?,
      industry: json['industry'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      selectedSessions:
          (json['selectedSessions'] as List<dynamic>?)
              ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      registrationStatus: RegistrationStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['registrationStatus'] ?? 'pending'),
        orElse: () => RegistrationStatus.pending,
      ),
      attendanceStatus: AttendanceStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['attendanceStatus'] ?? 'notCheckedIn'),
        orElse: () => AttendanceStatus.notCheckedIn,
      ),
      qrCodeId: json['qrCodeId'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
      customFields: json['customFields'] as Map<String, dynamic>?,
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
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

  String get fullAddress {
    final parts = [city, region].where((part) => part?.isNotEmpty == true);
    return parts.join(', ');
  }

  bool get hasCheckedIn =>
      attendanceStatus == AttendanceStatus.checkedIn ||
      attendanceStatus == AttendanceStatus.checkedOut;
  bool get hasLeft => attendanceStatus == AttendanceStatus.checkedOut;
  bool get isCancelled => registrationStatus == RegistrationStatus.cancelled;

  // Participant-specific helper methods
  bool get isConfirmed => registrationStatus == RegistrationStatus.confirmed;
  bool get isNoShow => attendanceStatus == AttendanceStatus.noShow;
  @override
  bool get isPending => registrationStatus == RegistrationStatus.pending;
  bool get isPresent => attendanceStatus == AttendanceStatus.checkedIn;

  bool get isWaitlisted => registrationStatus == RegistrationStatus.waitlisted;
  @override
  List<Object?> get props => [
    ...super.props,
    gender,
    dateOfBirth,
    nationality,
    region,
    city,
    woreda,
    idNumber,
    occupation,
    organization,
    department,
    industry,
    yearsOfExperience,
    selectedSessions,
    registrationStatus,
    attendanceStatus,
    qrCodeId,
    lastUpdatedAt,
    customFields,
  ];

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

  int get sessionsCount => selectedSessions.length;

  Participant copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? gender,
    DateTime? dateOfBirth,
    String? nationality,
    String? region,
    String? city,
    String? woreda,
    String? idNumber,
    String? occupation,
    String? organization,
    String? department,
    String? industry,
    int? yearsOfExperience,
    List<Session>? selectedSessions,
    DateTime? createdAt,
    RegistrationStatus? registrationStatus,
    AttendanceStatus? attendanceStatus,
    String? qrCodeId,
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? customFields,
    UserStatus? status,
    DateTime? lastLoginAt,
    String? profilePhotoUrl,
  }) {
    return Participant(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      region: region ?? this.region,
      city: city ?? this.city,
      woreda: woreda ?? this.woreda,
      idNumber: idNumber ?? this.idNumber,
      occupation: occupation ?? this.occupation,
      organization: organization ?? this.organization,
      department: department ?? this.department,
      industry: industry ?? this.industry,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      selectedSessions: selectedSessions ?? this.selectedSessions,
      createdAt: createdAt ?? this.createdAt,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      customFields: customFields ?? this.customFields,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = toBaseJson();
    return {
      ...baseJson,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'region': region,
      'city': city,
      'woreda': woreda,
      'idNumber': idNumber,
      'occupation': occupation,
      'organization': organization,
      'department': department,
      'industry': industry,
      'yearsOfExperience': yearsOfExperience,
      'selectedSessions': selectedSessions.map((e) => e.toJson()).toList(),
      'registrationStatus': registrationStatus.toString().split('.').last,
      'attendanceStatus': attendanceStatus.toString().split('.').last,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'qrCodeId': qrCodeId,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'customFields': customFields,
    };
  }
}

enum RegistrationStatus { pending, confirmed, cancelled, waitlisted }
