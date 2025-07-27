enum SessionStatus {
  active,
  inactive,
  full,
  cancelled,
  completed,
}

class Session {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String roomOrLocation; // Renamed from 'location'
  final String? speakerName; // Renamed from 'speaker'
  final String? speakerBio;
  final String? speakerPhotoUrl;
  final int capacity;
  final int currentAttendees;
  final SessionStatus status;
  final String? eventId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? tags;
  final String? prerequisites;
  final String? materials;

  const Session({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.roomOrLocation,
    this.speakerName,
    this.speakerBio,
    this.speakerPhotoUrl,
    required this.capacity,
    this.currentAttendees = 0,
    this.status = SessionStatus.active,
    this.eventId,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.prerequisites,
    this.materials,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      roomOrLocation: json['roomOrLocation'] as String,
      speakerName: json['speakerName'] as String?,
      speakerBio: json['speakerBio'] as String?,
      speakerPhotoUrl: json['speakerPhotoUrl'] as String?,
      capacity: json['capacity'] as int,
      currentAttendees: json['currentAttendees'] as int? ?? 0,
      status: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SessionStatus.active,
      ),
      eventId: json['eventId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      prerequisites: json['prerequisites'] as String?,
      materials: json['materials'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'roomOrLocation': roomOrLocation,
      'speakerName': speakerName,
      'speakerBio': speakerBio,
      'speakerPhotoUrl': speakerPhotoUrl,
      'capacity': capacity,
      'currentAttendees': currentAttendees,
      'status': status.toString().split('.').last,
      'eventId': eventId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
      'prerequisites': prerequisites,
      'materials': materials,
    };
  }

  Session copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? roomOrLocation,
    String? speakerName,
    String? speakerBio,
    String? speakerPhotoUrl,
    int? capacity,
    int? currentAttendees,
    SessionStatus? status,
    String? eventId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? prerequisites,
    String? materials,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomOrLocation: roomOrLocation ?? this.roomOrLocation,
      speakerName: speakerName ?? this.speakerName,
      speakerBio: speakerBio ?? this.speakerBio,
      speakerPhotoUrl: speakerPhotoUrl ?? this.speakerPhotoUrl,
      capacity: capacity ?? this.capacity,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      prerequisites: prerequisites ?? this.prerequisites,
      materials: materials ?? this.materials,
    );
  }

  // Helper methods
  bool get isFull => currentAttendees >= capacity;
  bool get isActive => status == SessionStatus.active;
  bool get isInactive => status == SessionStatus.inactive;
  bool get isCancelled => status == SessionStatus.cancelled;
  bool get isCompleted => status == SessionStatus.completed;

  bool get canRegister => isActive && !isFull && !hasStarted;

  Duration get duration => endTime.difference(startTime);

  bool get hasStarted => DateTime.now().isAfter(startTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);
  bool get isOngoing => hasStarted && !hasEnded;

  int get availableSpots => capacity - currentAttendees;
  double get occupancyRate =>
      capacity > 0 ? (currentAttendees / capacity) : 0.0;

  String get statusDisplay {
    switch (status) {
      case SessionStatus.active:
        return 'Active';
      case SessionStatus.inactive:
        return 'Inactive';
      case SessionStatus.full:
        return 'Full';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.completed:
        return 'Completed';
    }
  }

  String get timeRange {
    final startFormatted =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormatted =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startFormatted - $endFormatted';
  }

  String get durationDisplay {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}