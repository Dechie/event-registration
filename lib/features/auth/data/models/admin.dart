enum AdminRole { superAdmin, eventManager, checkInStaff }

class Admin {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final AdminRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profilePhotoUrl;

  const Admin({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.profilePhotoUrl,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => AdminRole.checkInStaff, // Default or handle error
      ),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  Admin copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    AdminRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profilePhotoUrl,
  }) {
    return Admin(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  // Helper methods
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
}
