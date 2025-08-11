import 'package:flutter/material.dart' show debugPrint;

class EventSession {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isActive;

  EventSession({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    required this.isActive,
  });

  factory EventSession.fromJson(Map<String, dynamic> json) {
    debugPrint("event session , is acive: ${json["is_active"]}");

    bool isActive = false;
    if (json["is_active"] is int) {
      debugPrint("is active is an int");
      if (json["is_active"] == 1) {
        isActive = true;
      } else if (json["is_active"] == 0) {
        isActive = false;
      }
    }

    return EventSession(
      id: json['id'].toString(),
      eventId: json['event_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'title': title,
      'description': description,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_active': isActive,
    };
  }
}
