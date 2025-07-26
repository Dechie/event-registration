class DashboardStats {
  final int totalRegistrants;
  final int checkedInAttendees;
  final int noShows;
  final Map<String, int> sessionAttendance;
  final DateTime lastUpdated;

  const DashboardStats({
    required this.totalRegistrants,
    required this.checkedInAttendees,
    required this.noShows,
    required this.sessionAttendance,
    required this.lastUpdated,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRegistrants: json['totalRegistrants'] as int,
      checkedInAttendees: json['checkedInAttendees'] as int,
      noShows: json['noShows'] as int,
      sessionAttendance: Map<String, int>.from(
        json['sessionAttendance'] as Map,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRegistrants': totalRegistrants,
      'checkedInAttendees': checkedInAttendees,
      'noShows': noShows,
      'sessionAttendance': sessionAttendance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  DashboardStats copyWith({
    int? totalRegistrants,
    int? checkedInAttendees,
    int? noShows,
    Map<String, int>? sessionAttendance,
    DateTime? lastUpdated,
  }) {
    return DashboardStats(
      totalRegistrants: totalRegistrants ?? this.totalRegistrants,
      checkedInAttendees: checkedInAttendees ?? this.checkedInAttendees,
      noShows: noShows ?? this.noShows,
      sessionAttendance: sessionAttendance ?? this.sessionAttendance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
