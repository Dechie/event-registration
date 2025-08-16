// lib/features/reports/data/models/participant_stats.dart
class ParticipantStats {
  final int total;
  final int approved;
  final int pending;
  final int rejected;

  ParticipantStats({
    required this.total,
    required this.approved,
    required this.pending,
    required this.rejected,
  });

  factory ParticipantStats.fromJson(Map<String, dynamic> json) {
    return ParticipantStats(
      total: json['total'] ?? 0,
      approved: json['approved'] ?? 0,
      pending: json['pending'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
    };
  }

  double get approvalRate => total > 0 ? (approved / total) * 100 : 0.0;

  @override
  String toString() {
    return 'ParticipantStats(total: $total, approved: $approved, pending: $pending, rejected: $rejected)';
  }
}

