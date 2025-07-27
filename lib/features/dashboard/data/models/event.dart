import 'package:event_reg/features/dashboard/data/models/session.dart';

enum EventStatus {
  draft,
  published,
  ongoing,
  completed,
  cancelled,
}

class Event {
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
  final DateTime? registrationDeadline;
  final List<Session> sessions;
  final EventStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? maxParticipants;
  final int currentParticipants;
  final String? organizerName;
  final String? organizerEmail;

  const Event({
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
    this.registrationDeadline,
    this.sessions = const [],
    this.status = EventStatus.draft,
    this.createdAt,
    this.updatedAt,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.organizerName,
    this.organizerEmail,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
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
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.parse(json['registrationDeadline'] as String)
          : null,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: EventStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => EventStatus.draft,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      maxParticipants: json['maxParticipants'] as int?,
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      organizerName: json['organizerName'] as String?,
      organizerEmail: json['organizerEmail'] as String?,
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
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'organizerName': organizerName,
      'organizerEmail': organizerEmail,
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? address,
    String? googleMapsLink,
    String? contactInfo,
    String? bannerUrl,
    DateTime? registrationDeadline,
    List<Session>? sessions,
    EventStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? maxParticipants,
    int? currentParticipants,
    String? organizerName,
    String? organizerEmail,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      address: address ?? this.address,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
      contactInfo: contactInfo ?? this.contactInfo,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      sessions: sessions ?? this.sessions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      organizerName: organizerName ?? this.organizerName,
      organizerEmail: organizerEmail ?? this.organizerEmail,
    );
  }

  // Helper methods
  bool get isDraft => status == EventStatus.draft;
  bool get isPublished => status == EventStatus.published;
  bool get isOngoing => status == EventStatus.ongoing;
  bool get isCompleted => status == EventStatus.completed;
  bool get isCancelled => status == EventStatus.cancelled;

  bool get isRegistrationOpen {
    if (registrationDeadline == null) return isPublished;
    return isPublished && DateTime.now().isBefore(registrationDeadline!);
  }

  bool get isFull {
    if (maxParticipants == null) return false;
    return currentParticipants >= maxParticipants!;
  }

  Duration get duration => endDate.difference(startDate);

  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;

  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get hasEnded => DateTime.now().isAfter(endDate);

  String get statusDisplay {
    switch (status) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Published';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }

  List<Session> get activeSessions =>
      sessions.where((session) => session.isActive).toList();

  int get totalCapacity =>
      sessions.fold(0, (sum, session) => sum + session.capacity);

  int get totalCurrentAttendees =>
      sessions.fold(0, (sum, session) => sum + session.currentAttendees);
}