enum UserType { none, participant, admin }

class AuthStatus {
  final UserType userType;
  final String? token;
  final String? email;

  AuthStatus({
    required this.userType,
    this.token,
    this.email,
  });
}