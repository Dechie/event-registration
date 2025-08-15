import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String speaker;
  final int maxCapacity;
  final int currentAttendance;
  final String status; // 'upcoming', 'ongoing', 'completed'
  final List<String> tags;
  final String? sessionType; // 'keynote', 'workshop', 'panel', etc.
  final Map<String, dynamic>? additionalInfo;

  const Session({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.speaker,
    required this.maxCapacity,
    required this.currentAttendance,
    required this.status,
    required this.tags,
    this.sessionType,
    this.additionalInfo,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['end_time'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      speaker: json['speaker'] ?? '',
      maxCapacity: json['max_capacity'] ?? 0,
      currentAttendance: json['current_attendance'] ?? 0,
      status: json['status'] ?? 'upcoming',
      tags: List<String>.from(json['tags'] ?? []),
      sessionType: json['session_type'],
      additionalInfo: json['additional_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'speaker': speaker,
      'max_capacity': maxCapacity,
      'current_attendance': currentAttendance,
      'status': status,
      'tags': tags,
      'session_type': sessionType,
      'additional_info': additionalInfo,
    };
  }

  bool get isFull => currentAttendance >= maxCapacity;
  bool get isUpcoming => status == 'upcoming';
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';
  double get attendanceRate => maxCapacity > 0 ? currentAttendance / maxCapacity : 0.0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        endTime,
        location,
        speaker,
        maxCapacity,
        currentAttendance,
        status,
        tags,
        sessionType,
        additionalInfo,
      ];

  get currentAttendees => null;

  get capacity => null;
}