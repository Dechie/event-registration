

import 'dart:convert';

import 'package:flutter/material.dart' show debugPrint;

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
  final bool hasProfile;
  final bool profileRequired;

  User({
    required this.id,
    required this.email,
    this.name,
    this.fullName,
    this.role = 'participant',
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
    this.hasProfile = false,
    this.profileRequired = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint("User.fromJson() - Processing JSON: ${jsonEncode(json)}");
      
      // Extract participant data if nested
      Map<String, dynamic> profileData = {};
      if (json.containsKey('participant') && json['participant'] is Map<String, dynamic>) {
        profileData = json['participant'] as Map<String, dynamic>;
        debugPrint("Found participant data: ${jsonEncode(profileData)}");
      }

      final user = User(
        // Core user fields
        id: (json['id'] ?? json['user_id'] ?? '').toString(),
        email: json['email'] ?? '',
        name: json['name'],
        fullName: profileData['full_name'] ?? json['full_name'] ?? json['name'],
        role: _determineRole(json),
        organizationId: json['organization_id']?.toString(),
        verificationCode: json['verification_code'],
        emailVerifiedAt: _parseDateTime(json['email_verified_at']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),

        // Profile fields from participant object or direct fields
        phoneNumber: profileData['phone'] ?? json['phone_number'] ?? json['phone'],
        occupation: profileData['occupation'] ?? json['occupation'],
        organization: profileData['organization'] ?? json['organization'],
        gender: profileData['gender'] ?? json['gender'],
        dateOfBirth: _parseDateTime(profileData['date_of_birth'] ?? json['date_of_birth']),
        nationality: profileData['nationality'] ?? json['nationality'],
        region: profileData['region'] ?? json['region'],
        city: profileData['city'] ?? json['city'],
        woreda: profileData['woreda'] ?? json['woreda'],
        idNumber: profileData['id_number'] ?? json['id_number'] ?? json['identification_number'],
        department: profileData['department'] ?? json['department'],
        industry: profileData['industry'] ?? json['industry'],
        yearsOfExperience: _parseInteger(profileData['years_of_experience'] ?? json['years_of_experience']),
        photoPath: profileData['photo'] ?? json['photo_path'] ?? json['avatar'] ?? json['profile_photo'],
        hasProfile: json['has_profile'] ?? (profileData.isNotEmpty),
        profileRequired: json['profile_required'] ?? false,
      );
      
      debugPrint("✅ Created User: ${user.toString()}");
      debugPrint("✅ User role: ${user.role}");
      debugPrint("✅ Has profile: ${user.hasProfile}");
      
      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in User.fromJson: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON was: ${jsonEncode(json)}');
      throw FormatException('Failed to parse User from JSON: $e');
    }
  }

  /// Get display name
  String get displayName {
    if (fullName?.isNotEmpty == true) return fullName!;
    if (name?.isNotEmpty == true) return name!;
    return email.split('@').first;
  }

  /// Check if user has completed profile
  bool get hasCompletedProfile {
    return fullName?.isNotEmpty == true &&
        phoneNumber?.isNotEmpty == true &&
        occupation?.isNotEmpty == true &&
        organization?.isNotEmpty == true;
  }

  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

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
    bool? hasProfile,
    bool? profileRequired,
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
      hasProfile: hasProfile ?? this.hasProfile,
      profileRequired: profileRequired ?? this.profileRequired,
    );
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
      'has_profile': hasProfile,
      'profile_required': profileRequired,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role, hasProfile: $hasProfile)';
  }

  /// Fixed helper method to determine user role
  static String _determineRole(Map<String, dynamic> json) {
    debugPrint("_determineRole() - Processing: ${jsonEncode(json)}");
    
    // Check if role is already a string (set by auth_remote_datasource)
    if (json['role'] is String && json['role'].isNotEmpty) {
      debugPrint("Role found as string: ${json['role']}");
      return json['role'];
    }
    
    // If role is a map, extract the name
    if (json['role'] is Map<String, dynamic>) {
      final roleMap = json['role'] as Map<String, dynamic>;
      if (roleMap.containsKey('name')) {
        debugPrint("Role extracted from map: ${roleMap['name']}");
        return roleMap['name'].toString();
      }
    }
    
    // Fallbacks
    if (json['user_type'] != null) {
      debugPrint("Role from user_type: ${json['user_type']}");
      return json['user_type'].toString();
    }
    
    // Check if user has organization_id (might indicate admin)
    if (json['organization_id'] != null) {
      debugPrint("Role determined as admin (has organization_id)");
      return 'admin';
    }
    
    // Check if there's participant data (indicates participant)
    if (json.containsKey('participant')) {
      debugPrint("Role determined as participant (has participant data)");
      return 'participant';
    }
    
    debugPrint("Role defaulting to participant");
    return 'participant';
  }

  /// Helper method to safely parse DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint("Failed to parse DateTime: $value");
        return null;
      }
    }
    return null;
  }

  /// Helper method to safely parse integer
  static int? _parseInteger(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return int.parse(value);
      } catch (e) {
        debugPrint("Failed to parse integer: $value");
        return null;
      }
    }
    if (value is double) return value.toInt();
    return null;
  }
}