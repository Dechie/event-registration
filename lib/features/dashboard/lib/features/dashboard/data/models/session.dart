class Session {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? speaker;
  final int capacity;
  final int currentAttendees;
  final String status; // active, inactive, full

  const Session({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.speaker,
    required this.capacity,
    required this.currentAttendees,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      speaker: json['speaker'] as String?,
      capacity: json['capacity'] as int,
      currentAttendees: json['currentAttendees'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'speaker': speaker,
      'capacity': capacity,
      'currentAttendees': currentAttendees,
      'status': status,
    };
  }

  bool get isFull => currentAttendees >= capacity;
  bool get isActive => status == 'active';
}