// lib/features/reports/presentation/pages/event_report_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/event_report.dart';
import '../../data/models/session_summary.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widgets/attendance_chart.dart';
import '../widgets/stats_card.dart';
import 'session_report_page.dart';

class EventReportPage extends StatefulWidget {
  final int eventId;
  final String? eventTitle;

  const EventReportPage({super.key, required this.eventId, this.eventTitle});

  @override
  State<EventReportPage> createState() => _EventReportPageState();
}

class _EventReportPageState extends State<EventReportPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventTitle ?? 'Event Report'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReportBloc>().add(LoadEventReport(widget.eventId));
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

          if (state is EventReportLoaded) {
            return _buildEventReport(
              context,
              state.eventReport,
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
    context.read<ReportBloc>().add(LoadEventReport(widget.eventId));
  }

  Widget _buildAttendanceChart(
    EventReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Overview',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AttendanceChart(attendanceStats: report.attendanceStats, height: 200),
      ],
    );
  }

  Widget _buildAttendanceStats(
    EventReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Attendance',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total',
                value: report.attendanceStats.totalAttendance.toString(),
                subtitle: 'Attended',
                color: Colors.purple,
                icon: Icons.how_to_reg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Present',
                value: report.attendanceStats.present.toString(),
                subtitle:
                    '${report.attendanceStats.presentRate.toStringAsFixed(1)}%',
                color: Colors.green,
                icon: Icons.check,
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
                value: report.attendanceStats.lateComing.toString(),
                subtitle:
                    '${report.attendanceStats.lateRate.toStringAsFixed(1)}%',
                color: Colors.orange,
                icon: Icons.access_time,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Absent',
                value: report.attendanceStats.absent.toString(),
                subtitle:
                    '${report.attendanceStats.absentRate.toStringAsFixed(1)}%',
                color: Colors.red,
                icon: Icons.close,
              ),
            ),
          ],
        ),
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
                context.read<ReportBloc>().add(LoadEventReport(widget.eventId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader(
    EventReport report,
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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.event, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.eventTitle,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Event ID: ${report.eventId}',
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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${report.overallAttendanceRate.toStringAsFixed(1)}% Attendance',
                    style: TextStyle(
                      color: Colors.green[700],
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

  Widget _buildEventReport(
    BuildContext context,
    EventReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportBloc>().add(LoadEventReport(widget.eventId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header
            _buildEventHeader(report, textTheme, colorScheme),
            const SizedBox(height: 20),

            // Participant Statistics
            _buildParticipantStats(report, textTheme, colorScheme),
            const SizedBox(height: 20),

            // Overall Attendance Statistics
            _buildAttendanceStats(report, textTheme, colorScheme),
            const SizedBox(height: 20),

            // Attendance Chart
            _buildAttendanceChart(report, textTheme, colorScheme),
            const SizedBox(height: 20),

            // Sessions List
            _buildSessionsList(context, report, textTheme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantStats(
    EventReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participant Statistics',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total',
                value: report.participantStats.total.toString(),
                subtitle: 'Participants',
                color: Colors.blue,
                icon: Icons.people,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Approved',
                value: report.participantStats.approved.toString(),
                subtitle:
                    '${report.participantStats.approvalRate.toStringAsFixed(1)}%',
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
                title: 'Pending',
                value: report.participantStats.pending.toString(),
                subtitle: 'Reviews',
                color: Colors.orange,
                icon: Icons.pending,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Rejected',
                value: report.participantStats.rejected.toString(),
                subtitle: 'Applications',
                color: Colors.red,
                icon: Icons.cancel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    SessionSummary session,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<ReportBloc>(),
                child: SessionReportPage(
                  sessionId: session.sessionId,
                  sessionTitle: session.sessionName,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getSessionColor(session),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.sessionName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Session ID: ${session.sessionId}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSessionStat(
                    'Total',
                    session.totalAttendance,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildSessionStat('Present', session.present, Colors.green),
                  const SizedBox(width: 16),
                  _buildSessionStat('Late', session.late, Colors.orange),
                  const SizedBox(width: 16),
                  _buildSessionStat('Absent', session.absent, Colors.red),
                ],
              ),
              if (session.totalAttendance > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: session.present / session.totalAttendance,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 4,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(session.present / session.totalAttendance * 100).toStringAsFixed(1)}% present',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList(
    BuildContext context,
    EventReport report,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sessions (${report.sessions.length})',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...report.sessions.map(
          (session) =>
              _buildSessionCard(context, session, textTheme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildSessionStat(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Color _getSessionColor(SessionSummary session) {
    if (session.totalAttendance == 0) return Colors.grey;
    final presentRate = session.present / session.totalAttendance;
    if (presentRate >= 0.8) return Colors.green;
    if (presentRate >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
