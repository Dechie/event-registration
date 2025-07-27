// lib/features/auth/data/models/admin.dart
import 'package:event_reg/core/shared/models/user.dart';

enum AdminRole { superAdmin, eventManager, checkInStaff }

class Admin extends BaseUser {
  final AdminRole role;
  final List<String> permissions;
  final String? department;
  final DateTime? lastActiveAt;

  const Admin({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required this.role,
    this.permissions = const [],
    this.department,
    super.status,
    required super.createdAt,
    super.lastLoginAt,
    this.lastActiveAt,
    super.profilePhotoUrl,
  }) : super(userType: UserType.admin);

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => AdminRole.checkInStaff,
      ),
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      department: json['department'] as String?,
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = toBaseJson();
    return {
      ...baseJson,
      'role': role.toString().split('.').last,
      'permissions': permissions,
      'department': department,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  Admin copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    AdminRole? role,
    List<String>? permissions,
    String? department,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    String? profilePhotoUrl,
  }) {
    return Admin(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      department: department ?? this.department,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  // Admin-specific helper methods
  bool get isSuperAdmin => role == AdminRole.superAdmin;
  bool get isEventManager => role == AdminRole.eventManager;
  bool get isCheckInStaff => role == AdminRole.checkInStaff;

  String get roleDisplayName {
    switch (role) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.eventManager:
        return 'Event Manager';
      case AdminRole.checkInStaff:
        return 'Check-in Staff';
    }
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission) || isSuperAdmin;
  }

  bool get canManageEvents =>
      hasPermission('manage_events') || isSuperAdmin || isEventManager;

  bool get canManageUsers => hasPermission('manage_users') || isSuperAdmin;

  bool get canCheckInParticipants =>
      hasPermission('check_in') ||
      isSuperAdmin ||
      isEventManager ||
      isCheckInStaff;

  bool get canViewReports =>
      hasPermission('view_reports') || isSuperAdmin || isEventManager;

  @override
  List<Object?> get props => [
    ...super.props,
    role,
    permissions,
    department,
    lastActiveAt,
  ];
}
