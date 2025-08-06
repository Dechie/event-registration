class AuthStatus {
  final Role role;
  final String? token;
  final String? email;
  final String? userId;
  final bool isEmailVerified;
  final bool hasProfile;
  final bool isProfileCompleted;

  const AuthStatus({
    required this.role,
    this.token,
    this.email,
    this.userId,
    this.isEmailVerified = false,
    this.hasProfile = false,
    this.isProfileCompleted = false,
  });

  factory AuthStatus.admin({
    required String token,
    required String email,
    required String userId,
    bool isEmailVerified =
        true, // Admins typically don't need email verification
    bool hasProfile = true, // Admins typically don't need profile setup
    bool isProfileCompleted = true,
  }) => AuthStatus(
    role: Role.admin,
    token: token,
    email: email,
    userId: userId,
    isEmailVerified: isEmailVerified,
    hasProfile: hasProfile,
    isProfileCompleted: isProfileCompleted,
  );

  factory AuthStatus.fromJson(Map<String, dynamic> json) {
    return AuthStatus(
      role: Role.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => Role.none,
      ),
      token: json['token'] as String?,
      email: json['email'] as String?,
      userId: json['userId'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      hasProfile: json['hasProfile'] as bool? ?? false,
      isProfileCompleted: json['isProfileCompleted'] as bool? ?? false,
    );
  }

  factory AuthStatus.participant({
    required String token,
    required String email,
    required String userId,
    bool isEmailVerified = false,
    bool hasProfile = false,
    bool isProfileCompleted = false,
  }) => AuthStatus(
    role: Role.participant,
    token: token,
    email: email,
    userId: userId,
    isEmailVerified: isEmailVerified,
    hasProfile: hasProfile,
    isProfileCompleted: isProfileCompleted,
  );

  // Factory constructors for common states
  factory AuthStatus.unauthenticated() => const AuthStatus(
    role: Role.none,
    token: null,
    userId: null,
    email: null,
    isEmailVerified: false,
    hasProfile: false,
    isProfileCompleted: false,
  );

  bool get isAdmin => role == Role.admin;

  // Computed properties
  bool get isAuthenticated =>
      role != Role.none && token != null && token!.isNotEmpty;
  bool get isFullySetup =>
      isAuthenticated && isEmailVerified && hasProfile && isProfileCompleted;
  bool get isParticipant => role == Role.participant;

  // Navigation decision helpers
  bool get needsEmailVerification => isAuthenticated && !isEmailVerified;
  bool get needsProfileCompletion =>
      isAuthenticated && isEmailVerified && hasProfile && !isProfileCompleted;
  bool get needsProfileCreation =>
      isAuthenticated && isEmailVerified && !hasProfile;
  // Where should the user be routed?
  NavDestination get recommendedDestination {
    if (!isAuthenticated) {
      return NavDestination.registration;
    }

    if (needsEmailVerification) {
      return NavDestination.emailVerification;
    }

    // For admins, skip profile creation and go directly to dashboard
    if (isAdmin && isEmailVerified) {
      return NavDestination.adminDashboard;
    }

    // For participants, check profile requirements
    if (isParticipant) {
      if (needsProfileCreation || needsProfileCompletion) {
        return NavDestination.profileCreation;
      }
      
      if (isFullySetup) {
        return NavDestination.participantDashboard;
      }
    }

    return NavDestination.landing;
  }

  AuthStatus copyWith({
    Role? role,
    String? token,
    String? email,
    String? userId,
    bool? isEmailVerified,
    bool? hasProfile,
    bool? isProfileCompleted,
  }) {
    return AuthStatus(
      role: role ?? this.role,
      token: token ?? this.token,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      hasProfile: hasProfile ?? this.hasProfile,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.toString().split('.').last,
      'token': token,
      'email': email,
      'userId': userId,
      'isEmailVerified': isEmailVerified,
      'hasProfile': hasProfile,
      'isProfileCompleted': isProfileCompleted,
    };
  }

  @override
  String toString() {
    return 'AuthStatus(role: $Role, isAuth: $isAuthenticated, emailVerified: $isEmailVerified, hasProfile: $hasProfile, profileCompleted: $isProfileCompleted)';
  }
}

enum NavDestination {
  registration,
  emailVerification,
  profileCreation,
  landing,
  participantDashboard,
  adminDashboard,
}

enum Role { none, participant, admin }
