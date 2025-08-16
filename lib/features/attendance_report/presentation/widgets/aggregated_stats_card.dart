// lib/features/attendance_report/presentation/widgets/aggregated_stats_card.dart
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../../data/models/aggregated_stats.dart';

class AggregatedStatsCard extends StatelessWidget {
  final AggregatedStats stats;

  const AggregatedStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Overall Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid of stats
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatItem(
                  'Total Sessions',
                  stats.totalSessions.toString(),
                  Icons.event,
                  AppColors.primary,
                ),
                _buildStatItem(
                  'Total Rounds',
                  stats.totalRounds.toString(),
                  Icons.group,
                  AppColors.secondary,
                ),
                _buildStatItem(
                  'Present',
                  stats.present.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Late',
                  stats.late.toString(),
                  Icons.schedule,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Absent',
                  stats.absent.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
                _buildStatItem(
                  'Attendance Rate',
                  '${stats.attendanceRatePercent.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  stats.attendanceRatePercent >= 80
                      ? Colors.green
                      : stats.attendanceRatePercent >= 60
                      ? Colors.orange
                      : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
