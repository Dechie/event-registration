// lib/features/reports/presentation/pages/session_report_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/location_report.dart';
import '../../data/models/session_report.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widgets/attendance_chart.dart';
import '../widgets/location_chart.dart';
import '../widgets/stats_card.dart';

class SessionReportPage extends StatefulWidget {
  final int sessionId;
  final String? sessionTitle;

  const SessionReportPage({
    super.key,
    required this.sessionId,
    this.sessionTitle,
  });

  @override
  State<SessionReportPage> createState() => _SessionReportPageState();
}

class _SessionReportPageState extends State<SessionReportPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionTitle ?? 'Session Report'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReportBloc>().add(
                LoadSessionReport(widget.sessionId),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportError) {
            return _buildErrorState(context, state, textTheme, colorScheme);
          }

          if (state is SessionReportLoaded) {
            return _buildSessionReport(
              context,
              state.sessionReport,
              textTheme,
              colorScheme,
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadSessionReport(widget.sessionId));
  }

  Widget _buildAttendanceChart(
    SessionReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Breakdown',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AttendanceChart(attendanceStats: report.overallStats, height: 200),
      ],
    );
  }

  Widget _buildAttendanceStatItem(
    String label,
    int value,
    double percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityInfo(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ReportError state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Report',
              style: textTheme.headlineSmall?.copyWith(color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ReportBloc>().add(
                  LoadSessionReport(widget.sessionId),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    LocationReport location,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final utilizationColor = _getUtilizationColor(location.utilizationRate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: utilizationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: utilizationColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.locationName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${location.locationId}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: utilizationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${location.utilizationRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: utilizationColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Capacity Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCapacityInfo(
                      'Capacity',
                      location.capacity,
                      Icons.event_seat,
                      Colors.purple,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildCapacityInfo(
                      'Allocated',
                      location.allocated,
                      Icons.assignment,
                      Colors.blue,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildCapacityInfo(
                      'Attended',
                      location.stats.totalAttendance,
                      Icons.how_to_reg,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Attendance Statistics
            Text(
              'Attendance Statistics',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceStatItem(
                    'Present',
                    location.stats.present,
                    location.stats.presentRate,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildAttendanceStatItem(
                    'Late',
                    location.stats.lateComing,
                    location.stats.lateRate,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildAttendanceStatItem(
                    'Absent',
                    location.stats.absent,
                    location.stats.absentRate,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsList(
    BuildContext context,
    SessionReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (report.locations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.location_off,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Locations',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This session has no locations configured.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details (${report.locations.length})',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...report.locations.map(
          (location) => _buildLocationCard(location, textTheme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildLocationsOverview(
    SessionReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final totalCapacity = report.locations.fold<int>(
      0,
      (sum, loc) => sum + loc.capacity,
    );
    final totalAllocated = report.locations.fold<int>(
      0,
      (sum, loc) => sum + loc.allocated,
    );
    final totalAttended = report.locations.fold<int>(
      0,
      (sum, loc) => sum + loc.stats.totalAttendance,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Locations Overview',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildOverviewStat(
                        'Total Capacity',
                        totalCapacity.toString(),
                        Icons.event_seat,
                        Colors.purple,
                      ),
                    ),
                    Expanded(
                      child: _buildOverviewStat(
                        'Allocated',
                        totalAllocated.toString(),
                        Icons.assignment,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildOverviewStat(
                        'Attended',
                        totalAttended.toString(),
                        Icons.how_to_reg,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LocationChart(locations: report.locations),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallStats(
    SessionReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Session Statistics',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total',
                value: report.overallStats.totalAttendance.toString(),
                subtitle: 'Attendance',
                color: Colors.blue,
                icon: Icons.how_to_reg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Present',
                value: report.overallStats.present.toString(),
                subtitle:
                    '${report.overallStats.presentRate.toStringAsFixed(1)}%',
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Late',
                value: report.overallStats.lateComing.toString(),
                subtitle: '${report.overallStats.lateRate.toStringAsFixed(1)}%',
                color: Colors.orange,
                icon: Icons.access_time,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Absent',
                value: report.overallStats.absent.toString(),
                subtitle:
                    '${report.overallStats.absentRate.toStringAsFixed(1)}%',
                color: Colors.red,
                icon: Icons.cancel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSessionHeader(
    SessionReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.schedule, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.sessionName,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Session ID: ${report.sessionId} • Event ID: ${report.eventId}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${report.locations.length} Locations',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionReport(
    BuildContext context,
    SessionReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportBloc>().add(LoadSessionReport(widget.sessionId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Header
            _buildSessionHeader(report, textTheme, colorScheme),
            const SizedBox(height: 20),

            // Overall Session Statistics
            _buildOverallStats(report, textTheme, colorScheme),
            const SizedBox(height: 20),

            // Attendance Chart
            _buildAttendanceChart(report, textTheme, colorScheme),
            const SizedBox(height: 20),

            // Locations Overview
            if (report.locations.isNotEmpty) ...[
              _buildLocationsOverview(report, textTheme, colorScheme),
              const SizedBox(height: 20),
            ],

            // Location Details
            _buildLocationsList(context, report, textTheme, colorScheme),
          ],
        ),
      ),
    );
  }

  Color _getUtilizationColor(double utilizationRate) {
    if (utilizationRate >= 90) {
      return Colors.red;
    } else if (utilizationRate >= 70) {
      return Colors.orange;
    } else if (utilizationRate >= 50) {
      return Colors.yellow[700]!;
    } else {
      return Colors.green;
    }
  }
}
