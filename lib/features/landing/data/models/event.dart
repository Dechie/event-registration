import 'package:event_reg/features/landing/data/models/event_session.dart';

import 'organization.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String? banner;
  final String organizationId;
  final Organization? organization;
  final List<EventSession>? sessions;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.banner,
    required this.organizationId,
    this.organization,
    this.sessions,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    bool isActive = false;
    if (json["isActive"] is int) {
      if (json["is_active"] == 1) {
        isActive = false;
      } else if (json["is_active"] == 0) {
        isActive = true;
      }
    }
    return Event(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isActive: isActive, 
      banner: json['banner'],
      organizationId: json['organization_id'].toString(),
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      sessions: json['sessions'] != null
          ? (json['sessions'] as List)
                .map((session) => EventSession.fromJson(session))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
      'banner': banner,
      'organization_id': organizationId,
      'organization': organization?.toJson(),
      'sessions': sessions?.map((session) => session.toJson()).toList(),
    };
  }
}
