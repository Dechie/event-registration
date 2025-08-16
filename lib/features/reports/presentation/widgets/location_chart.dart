// lib/features/reports/presentation/widgets/location_chart.dart
import 'package:flutter/material.dart';

import '../../data/models/location_report.dart';

class LocationChart extends StatelessWidget {
  final List<LocationReport> locations;
  final double height;

  const LocationChart({super.key, required this.locations, this.height = 230});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No location data',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final maxCapacity = locations.fold<int>(
      0,
      (max, location) => location.capacity > max ? location.capacity : max,
    );

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Chart Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location Utilization',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildChartLegend('Capacity', Colors.grey[300]!),
                const SizedBox(width: 16),
                _buildChartLegend('Allocated', Colors.blue),
                const SizedBox(width: 16),
                _buildChartLegend('Attended', Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bar Chart
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: locations.map((location) {
                  return _buildLocationBar(location, maxCapacity);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildLocationBar(LocationReport location, int maxCapacity) {
    final barHeight = height * 0.5; // 50% of total height for bars
    final capacityHeight = maxCapacity > 0
        ? (location.capacity / maxCapacity) * barHeight
        : 0.0;
    final allocatedHeight = maxCapacity > 0
        ? (location.allocated / maxCapacity) * barHeight
        : 0.0;
    final attendedHeight = maxCapacity > 0
        ? (location.stats.totalAttendance / maxCapacity) * barHeight
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Values on top of bars
          if (location.stats.totalAttendance > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Text(
                location.stats.totalAttendance.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),

          // Bar stack
          SizedBox(
            width: 40,
            height: barHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Capacity bar (background)
                Container(
                  width: 40,
                  height: capacityHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Allocated bar
                Container(
                  width: 32,
                  height: allocatedHeight,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Attended bar
                Container(
                  width: 24,
                  height: attendedHeight,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Location name
          SizedBox(
            width: 60,
            child: Text(
              location.locationName,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Utilization percentage
          Text(
            '${location.utilizationRate.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
