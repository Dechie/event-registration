class Organization {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? website;
  final String? logo;

  Organization({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.website,
    this.logo,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'website': website,
      'logo': logo,
    };
  }
}
