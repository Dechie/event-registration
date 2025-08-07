// class AuthStatus {
//   final Role role;
//   final String? token;
//   final String? email;
//   final String? userId;
//   final bool isEmailVerified;
//   final bool hasProfile;

//   const AuthStatus({
//     required this.role,
//     this.token,
//     this.email,
//     this.userId,
//     this.isEmailVerified = false,
//     this.hasProfile = false,
//   });

//   factory AuthStatus.admin({
//     required String token,
//     required String email,
//     required String userId,
//     bool isEmailVerified =
//         true, // Admins typically don't need email verification
//     bool hasProfile = true, // Admins typically don't need profile setup
//     bool isProfileCompleted = true,
//   }) => AuthStatus(
//     role: Role.admin,
//     token: token,
//     email: email,
//     userId: userId,
//     isEmailVerified: isEmailVerified,
//     hasProfile: hasProfile,
//   );

//   factory AuthStatus.fromJson(Map<String, dynamic> json) {
//     return AuthStatus(
//       role: Role.values.firstWhere(
//         (e) => e.toString().split('.').last == json['role'],
//         orElse: () => Role.none,
//       ),
//       token: json['token'] as String?,
//       email: json['email'] as String?,
//       userId: json['userId'] as String?,
//       isEmailVerified: json['isEmailVerified'] as bool? ?? false,
//       hasProfile: json['hasProfile'] as bool? ?? false,
//     );
//   }

//   factory AuthStatus.participant({
//     required String token,
//     required String email,
//     required String userId,
//     bool isEmailVerified = false,
//     bool hasProfile = false,
//     bool isProfileCompleted = false,
//   }) => AuthStatus(
//     role: Role.participant,
//     token: token,
//     email: email,
//     userId: userId,
//     isEmailVerified: isEmailVerified,
//     hasProfile: hasProfile,
//   );

//   // Factory constructors for common states
//   factory AuthStatus.unauthenticated() => const AuthStatus(
//     role: Role.none,
//     token: null,
//     userId: null,
//     email: null,
//     isEmailVerified: false,
//     hasProfile: false,
//   );

//   bool get isAdmin => role == Role.admin;

//   // Computed properties
//   bool get isAuthenticated =>
//       role != Role.none && token != null && token!.isNotEmpty;
//   bool get isFullySetup => isAuthenticated && isEmailVerified && hasProfile;
//   bool get isParticipant => role == Role.participant;

//   // Navigation decision helpers
//   bool get needsEmailVerification => isAuthenticated && !isEmailVerified;
//   bool get needsProfileCompletion =>
//       isAuthenticated && isEmailVerified && hasProfile;
//   bool get needsProfileCreation =>
//       isAuthenticated && isEmailVerified && !hasProfile;
//   // Where should the user be routed?
//   NavDestination get recommendedDestination {
//     if (!isAuthenticated) {
//       return NavDestination.registration;
//     }

//     if (needsEmailVerification) {
//       return NavDestination.emailVerification;
//     }

//     // For admins, skip profile creation and go directly to dashboard
//     if (isAdmin && isEmailVerified) {
//       return NavDestination.adminDashboard;
//     }

//     // For participants, check profile requirements
//     if (isParticipant) {
//       if (needsProfileCreation || needsProfileCompletion) {
//         return NavDestination.profileCreation;
//       }

//       if (isFullySetup) {
//         return NavDestination.participantDashboard;
//       }
//     }

//     return NavDestination.landing;
//   }

//   AuthStatus copyWith({
//     Role? role,
//     String? token,
//     String? email,
//     String? userId,
//     bool? isEmailVerified,
//     bool? hasProfile,
//     bool? isProfileCompleted,
//   }) {
//     return AuthStatus(
//       role: role ?? this.role,
//       token: token ?? this.token,
//       email: email ?? this.email,
//       userId: userId ?? this.userId,
//       isEmailVerified: isEmailVerified ?? this.isEmailVerified,
//       hasProfile: hasProfile ?? this.hasProfile,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'role': role.toString().split('.').last,
//       'token': token,
//       'email': email,
//       'userId': userId,
//       'isEmailVerified': isEmailVerified,
//       'hasProfile': hasProfile,
//     };
//   }

//   @override
//   String toString() {
//     return 'AuthStatus(role: $Role, isAuth: $isAuthenticated, emailVerified: $isEmailVerified, hasProfile: $hasProfile)';
//   }
// }

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
