enum UserType {
  none,
  participant,
  admin,
}

class AuthStatus {
  final UserType userType;
  final String? token;
  final String? email;
  final String? userId;

  const AuthStatus({
    required this.userType,
    this.token,
    this.email,
    this.userId,
  });

  factory AuthStatus.fromJson(Map<String, dynamic> json) {
    return AuthStatus(
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['userType'],
        orElse: () => UserType.none,
      ),
      token: json['token'] as String?,
      email: json['email'] as String?,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userType': userType.toString().split('.').last,
      'token': token,
      'email': email,
      'userId': userId,
    };
  }

  // Factory constructors for common states
  factory AuthStatus.unauthenticated() => const AuthStatus(
        userType: UserType.none,
        token: null,
        userId: null,
        email: null,
      );

  factory AuthStatus.participant({
    required String token,
    required String email,
    required String userId,
  }) =>
      AuthStatus(
        userType: UserType.participant,
        token: token,
        email: email,
        userId: userId,
      );

  factory AuthStatus.admin({
    required String token,
    required String email,
    required String userId,
  }) =>
      AuthStatus(
        userType: UserType.admin,
        token: token,
        email: email,
        userId: userId,
      );

  bool get isAuthenticated => userType != UserType.none && token != null;
  bool get isParticipant => userType == UserType.participant;
  bool get isAdmin => userType == UserType.admin;
}
