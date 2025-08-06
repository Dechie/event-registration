class LoginRequest {
  final String email;
  final String password;
  final String role;
  LoginRequest({
    required this.email,
    required this.password,
    required this.role,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json["email"] ?? '',
      password: json["password"] ?? '',
      role: json["role"] ?? 'participant',
    );
  }

  @override
  int get hashCode {
    return email.hashCode ^ password.hashCode ^ role.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.email == email &&
        other.password == password &&
        other.role == role;
  }

  LoginRequest copyWith({String? email, String? password, String? role}) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }

  @override
  String toString() {
    return 'LoginRequest(email: $email, role: $role)';
    // Don't include password in toString for security
  }
}
