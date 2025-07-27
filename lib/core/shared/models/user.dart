// lib/shared/models/base_user.dart
import 'package:equatable/equatable.dart';

enum UserType { participant, admin }

enum UserStatus { active, inactive, suspended, pending }

abstract class BaseUser extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserType userType;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profilePhotoUrl;

  const BaseUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.status = UserStatus.active,
    required this.createdAt,
    this.lastLoginAt,
    this.profilePhotoUrl,
  });

  // Common helper methods
  bool get isActive => status == UserStatus.active;
  bool get isInactive => status == UserStatus.inactive;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isPending => status == UserStatus.pending;
  bool get isParticipant => userType == UserType.participant;
  bool get isAdmin => userType == UserType.admin;

  String get displayName => fullName;
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return names.first.substring(0, 1).toUpperCase();
  }

  String get statusDisplay {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.pending:
        return 'Pending';
    }
  }

  String get userTypeDisplay {
    switch (userType) {
      case UserType.participant:
        return 'Participant';
      case UserType.admin:
        return 'Admin';
    }
  }

  // Base JSON serialization - to be extended by subclasses
  Map<String, dynamic> toBaseJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phoneNumber,
        userType,
        status,
        createdAt,
        lastLoginAt,
        profilePhotoUrl,
      ];
}

// Generic User class for basic operations
class User extends BaseUser {
  const User({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.userType,
    super.status,
    required super.createdAt,
    super.lastLoginAt,
    super.profilePhotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['userType'],
        orElse: () => UserType.participant,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => UserStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return toBaseJson();
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserType? userType,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profilePhotoUrl,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}