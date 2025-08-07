class AuthStatus {
  final Role role;
  final String? token;
  final String? email;
  final String? userId;
  final bool isEmailVerified;
  final bool hasProfile;

  const AuthStatus({
    required this.role,
    this.token,
    this.email,
    this.userId,
    this.isEmailVerified = false,
    this.hasProfile = false,
  });

  factory AuthStatus.admin({
    required String token,
    required String email,
    required String userId,
    bool isEmailVerified = true,
    bool hasProfile = true,
  }) => AuthStatus(
    role: Role.admin,
    token: token,
    email: email,
    userId: userId,
    isEmailVerified: isEmailVerified,
    hasProfile: hasProfile,
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
    );
  }

  factory AuthStatus.participant({
    required String token,
    required String email,
    required String userId,
    bool isEmailVerified = false,
    bool hasProfile = false,
  }) => AuthStatus(
    role: Role.participant,
    token: token,
    email: email,
    userId: userId,
    isEmailVerified: isEmailVerified,
    hasProfile: hasProfile,
  );

  factory AuthStatus.unauthenticated() => const AuthStatus(
    role: Role.none,
    token: null,
    userId: null,
    email: null,
    isEmailVerified: false,
    hasProfile: false,
  );

  // Basic role checks
  bool get isAdmin => role == Role.admin;
  // Updated computed properties based on new rules
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  bool get isFullySetup {
    if (!isAuthenticated || !isEmailVerified) return false;

    // Admin is fully setup once authenticated and email verified
    if (isAdmin) return true;

    // Participant needs profile creation as well
    if (isParticipant) return hasProfile;

    return false;
  }

  bool get isParticipant => role == Role.participant;

  // Updated navigation decision helpers
  bool get needsEmailVerification => role != Role.none && !isEmailVerified;

  bool get needsProfileCompletion =>
      isParticipant && isAuthenticated && isEmailVerified && hasProfile;

  bool get needsProfileCreation =>
      isParticipant && isAuthenticated && isEmailVerified && !hasProfile;

  // Updated routing logic
  NavDestination get recommendedDestination {
    // If no role is assigned, user hasn't registered yet
    if (role == Role.none) {
      return NavDestination.registration;
    }

    // If role is assigned but email not verified, user has registered but needs OTP verification
    if (role != Role.none && !isEmailVerified) {
      return NavDestination.emailVerification;
    }

    // If role assigned and email verified but no token, user needs to login
    if (role != Role.none && isEmailVerified && !isAuthenticated) {
      return role == Role.admin ? NavDestination.adminLogin : NavDestination.participantLogin;
    }

    // Once authenticated (has token) and email verified
    if (isAuthenticated && isEmailVerified) {
      // Admin goes straight to dashboard
      if (isAdmin) {
        return NavDestination.adminDashboard;
      }

      // Participant needs profile creation
      if (isParticipant) {
        if (!hasProfile) {
          return NavDestination.profileCreation;
        }
        // Once profile is created, go to participant dashboard

        return NavDestination.participantDashboard;
      }
    }

    return NavDestination.landing;
  }
}

enum NavDestination {
  registration,
  emailVerification,
  profileCreation,
  landing,
  participantDashboard,
  adminDashboard,
  adminLogin,
  participantLogin,
}

enum Role { none, participant, admin }
