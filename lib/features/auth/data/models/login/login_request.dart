class LoginRequest {
  final String email;
  final String password;
  final String userType;
  LoginRequest({
    required this.email,
    required this.password,
    required this.userType,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json["email"] ?? '',
      password: json["password"] ?? '',
      userType: json["userType"] ?? 'participant',
    );
  }

  @override
  int get hashCode {
    return email.hashCode ^ password.hashCode ^ userType.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.email == email &&
        other.password == password &&
        other.userType == userType;
  }

  LoginRequest copyWith({String? email, String? password, String? userType}) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
    );
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }

  @override
  String toString() {
    return 'LoginRequest(email: $email, userType: $userType)';
    // Don't include password in toString for security
  }
}
