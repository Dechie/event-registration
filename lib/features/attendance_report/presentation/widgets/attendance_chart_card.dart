// lib/features/attendance_report/presentation/widgets/attendance_chart_card.dart
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/features/attendance_report/data/models/attendance_report.dart';
import 'package:flutter/material.dart';

import '../../data/models/attendance_trend.dart';

class AttendanceChartCard extends StatelessWidget {
  final List<AttendanceTrend> attendanceTrend;

  const AttendanceChartCard({super.key, required this.attendanceTrend});

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
                Icon(Icons.timeline, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Attendance Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (attendanceTrend.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: attendanceTrend.map((trend) => 
                      _buildTrendBar(trend, context)).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(),
            ] else
              const Text('No trend data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBar(AttendanceTrend trend, BuildContext context) {
    final maxCount = attendanceTrend.map((t) => t.count).reduce((a, b) => a > b ? a : b);
    final barHeight = maxCount > 0 ? (trend.count / maxCount) * 150 : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar
          Container(
            width: 40,
            height: barHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Stack(
              children: [
                if (trend.present > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: (trend.present / trend.count) * barHeight,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                if (trend.late > 0)
                  Positioned(
                    bottom: (trend.present / trend.count) * barHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: (trend.late / trend.count) * barHeight,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Date label
          Text(
            trend.formattedDate,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          // Count
          Text(
            trend.count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Present', Colors.green),
        const SizedBox(width: 16),
        _buildLegendItem('Late', Colors.orange),
        const SizedBox(width: 16),
        _buildLegendItem('Absent', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

