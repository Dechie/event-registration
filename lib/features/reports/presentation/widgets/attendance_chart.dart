// lib/features/reports/presentation/widgets/attendance_chart.dart
import 'package:flutter/material.dart';

import '../../data/models/attendance_stats.dart';

class AttendanceChart extends StatelessWidget {
  final AttendanceStats attendanceStats;
  final double height;

  const AttendanceChart({
    super.key,
    required this.attendanceStats,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    final total = attendanceStats.totalAttendance;

    if (total == 0) {
      return Card(
        child: Container(
          height: height,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No attendance data',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Pie Chart (simplified as circular indicators)
            Expanded(
              flex: 2,
              child: Center(
                child: SizedBox(
                  width: height * 0.6,
                  height: height * 0.6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                        ),
                      ),
                      // Present segment
                      if (attendanceStats.present > 0)
                        _buildCircularSegment(
                          attendanceStats.present / total,
                          Colors.green,
                          0,
                        ),
                      // Late segment
                      if (attendanceStats.lateComing > 0)
                        _buildCircularSegment(
                          attendanceStats.lateComing / total,
                          Colors.orange,
                          attendanceStats.present / total,
                        ),
                      // Absent segment
                      if (attendanceStats.absent > 0)
                        _buildCircularSegment(
                          attendanceStats.absent / total,
                          Colors.red,
                          (attendanceStats.present +
                                  attendanceStats.lateComing) /
                              total,
                        ),
                      // Center text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            total.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Legend
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    'Present',
                    attendanceStats.present,
                    attendanceStats.presentRate,
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    'Late',
                    attendanceStats.lateComing,
                    attendanceStats.lateRate,
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    'Absent',
                    attendanceStats.absent,
                    attendanceStats.absentRate,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularSegment(
    double percentage,
    Color color,
    double startAngle,
  ) {
    return CustomPaint(
      size: Size.infinite,
      painter: CircularSegmentPainter(
        percentage: percentage,
        color: color,
        startAngle: startAngle * 2 * 3.14159, // Convert to radians
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    int value,
    double percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class CircularSegmentPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double startAngle;

  CircularSegmentPainter({
    required this.percentage,
    required this.color,
    required this.startAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle =
        percentage * 2 * 3.14159; // Convert percentage to radians

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
