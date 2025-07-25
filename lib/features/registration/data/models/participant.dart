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
    final List<String> selectedSessions;
    final DateTime createdAt;

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
        required this.selectedSessions,
        required this.createdAt,
    });

    // Factory constructor for JSON deserialization
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
      selectedSessions: List<String>.from(json['selectedSessions'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Method for JSON serialization
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
      'selectedSessions': selectedSessions,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // CopyWith method for immutable updates
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
    List<String>? selectedSessions,
    DateTime? createdAt,
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Participant &&
        other.id == id &&
        other.fullName == fullName &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ fullName.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'Participant(id: $id, fullName: $fullName, email: $email)';
  }
}
