class EventInfo {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String address;
  final String? googleMapsLink;
  final String contactInfo;
  final String? bannerUrl;

  const EventInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.address,
    this.googleMapsLink,
    required this.contactInfo,
    this.bannerUrl,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      venue: json['venue'] as String,
      address: json['address'] as String,
      googleMapsLink: json['googleMapsLink'] as String?,
      contactInfo: json['contactInfo'] as String,
      bannerUrl: json['bannerUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'venue': venue,
      'address': address,
      'googleMapsLink': googleMapsLink,
      'contactInfo': contactInfo,
      'bannerUrl': bannerUrl,
    };
  }
}