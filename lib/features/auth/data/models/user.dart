import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String userType; // 'participant' or 'admin'
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;
  
  // Event-specific fields (based on /me endpoint)
  final String? location;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? banner;

  const User({
    required this.id,
    required this.email,
    required this.userType,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePicture,
    this.isEmailVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
    this.location,
    this.startTime,
    this.endTime,
    this.banner,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      userType: json['user_type'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePicture: json['profile_picture'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      location: json['location'] as String?,
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String)
          : null,
      banner: json['banner'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'is_email_verified': isEmailVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
      'location': location,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'banner': banner,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? email.split('@').first;
  }

  bool get isAdmin => userType == 'admin';
  bool get isParticipant => userType == 'participant';

  User copyWith({
    String? id,
    String? email,
    String? userType,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String? banner,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      banner: banner ?? this.banner,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        userType,
        firstName,
        lastName,
        phoneNumber,
        profilePicture,
        isEmailVerified,
        isActive,
        createdAt,
        lastLoginAt,
        metadata,
        location,
        startTime,
        endTime,
        banner,
      ];
}

// Typedef for Admin (since they're both users with different types)
typedef Admin = User;
