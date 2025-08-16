// lib/features/attendance_report/presentation/widgets/round_metrics_card.dart
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../../data/models/round_metrics.dart';

class RoundMetricsCard extends StatelessWidget {
  final List<RoundMetrics> roundMetrics;

  const RoundMetricsCard({super.key, required this.roundMetrics});

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
                Icon(Icons.groups, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Round Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: roundMetrics.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final metrics = roundMetrics[index];
                return _buildRoundMetric(metrics);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundMetric(RoundMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metrics.roundName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildMetricChip(
                'Present',
                metrics.present.toString(),
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricChip(
                'Late',
                metrics.late.toString(),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricChip(
                'Absent',
                metrics.absent.toString(),
                Colors.red,
              ),
            ),
          ],
        ),

        if (metrics.avgLatenessMinutes > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  'Avg. Lateness: ${metrics.formattedAvgLateness}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
