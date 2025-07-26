class LoginResponse {
  final String token;
  final String email;
  final String name;
  final String userType;

  LoginResponse({
    required this.token,
    required this.email,
    required this.name,
    required this.userType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    userType: json['userType'] ?? '',
  );
}
