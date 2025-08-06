class User {
  final String id;
  final String email;
  final String? name;
  final String? fullName;
  final String role;
  final String? organizationId;
  final String? verificationCode;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? phoneNumber;
  final String? occupation;
  final String? organization;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? region;
  final String? city;
  final String? woreda;
  final String? idNumber;
  final String? department;
  final String? industry;
  final int? yearsOfExperience;
  final String? photoPath;

  User({
    required this.id,
    required this.email,
    this.name,
    this.fullName,
    this.role = 'participant', // Default value
    this.organizationId,
    this.verificationCode,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.phoneNumber,
    this.occupation,
    this.organization,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.region,
    this.city,
    this.woreda,
    this.idNumber,
    this.department,
    this.industry,
    this.yearsOfExperience,
    this.photoPath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        // Laravel backend fields
        id: (json['id'] ?? json['user_id'] ?? '').toString(),
        email: json['email'] ?? '',
        name: json['name'],
        fullName: json['full_name'] ?? json['name'], // Use name as fallback
        role: _determinerole(json),
        organizationId: json['organization_id']?.toString(),
        verificationCode: json['verification_code'],
        emailVerifiedAt: _parseDateTime(json['email_verified_at']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),

        // Additional profile fields (may not be present initially)
        phoneNumber: json['phone_number'] ?? json['phone'],
        occupation: json['occupation'],
        organization: json['organization'],
        gender: json['gender'],
        dateOfBirth: _parseDateTime(json['date_of_birth']),
        nationality: json['nationality'],
        region: json['region'],
        city: json['city'],
        woreda: json['woreda'],
        idNumber: json['id_number'] ?? json['identification_number'],
        department: json['department'],
        industry: json['industry'],
        yearsOfExperience: _parseInteger(json['years_of_experience']),
        photoPath: json['photo_path'] ?? json['avatar'] ?? json['profile_photo'],
      );
    } catch (e) {
      throw FormatException('Failed to parse User from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'full_name': fullName,
      'user_type': role,
      'organization_id': organizationId,
      'verification_code': verificationCode,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'phone_number': phoneNumber,
      'occupation': occupation,
      'organization': organization,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'region': region,
      'city': city,
      'woreda': woreda,
      'id_number': idNumber,
      'department': department,
      'industry': industry,
      'years_of_experience': yearsOfExperience,
      'photo_path': photoPath,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? fullName,
    String? role,
    String? organizationId,
    String? verificationCode,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    String? occupation,
    String? organization,
    String? gender,
    DateTime? dateOfBirth,
    String? nationality,
    String? region,
    String? city,
    String? woreda,
    String? idNumber,
    String? department,
    String? industry,
    int? yearsOfExperience,
    String? photoPath,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      verificationCode: verificationCode ?? this.verificationCode,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      occupation: occupation ?? this.occupation,
      organization: organization ?? this.organization,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      region: region ?? this.region,
      city: city ?? this.city,
      woreda: woreda ?? this.woreda,
      idNumber: idNumber ?? this.idNumber,
      department: department ?? this.department,
      industry: industry ?? this.industry,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  /// Helper method to determine user type
  /// You can customize this logic based on your backend implementation
  static String _determinerole(Map<String, dynamic> json) {
    // Check if there's an explicit user_type field
    if (json['user_type'] != null) {
      return json['user_type'].toString();
    }

    // Check if there's a role field
    if (json['role'] != null) {
      return json['role'].toString();
    }

    // Check organization_id to determine if admin
    if (json['organization_id'] != null) {
      return 'admin';
    }

    // Default to participant
    return 'participant';
  }

  /// Helper method to safely parse DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Helper method to safely parse integer
  static int? _parseInteger(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is double) return value.toInt();
    return null;
  }

  /// Check if user has completed profile
  bool get hasCompletedProfile {
    return fullName?.isNotEmpty == true &&
           phoneNumber?.isNotEmpty == true &&
           occupation?.isNotEmpty == true &&
           organization?.isNotEmpty == true;
  }

  /// Get display name
  String get displayName {
    if (fullName?.isNotEmpty == true) return fullName!;
    if (name?.isNotEmpty == true) return name!;
    return email.split('@').first; // Use email username as fallback
  }

  /// Check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}