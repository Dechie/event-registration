// lib/features/attendance_report/presentation/pages/attendance_report_page.dart
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/features/attendance_report/data/models/attendance_report.dart';
import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_bloc.dart';
import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_event.dart';
import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_state.dart';
import 'package:event_reg/features/attendance_report/presentation/widgets/aggregated_stats_card.dart';
import 'package:event_reg/features/attendance_report/presentation/widgets/attendance_chart_card.dart';
import 'package:event_reg/features/attendance_report/presentation/widgets/attendance_history_card.dart';
import 'package:event_reg/features/attendance_report/presentation/widgets/location_stats_card.dart';
import 'package:event_reg/features/attendance_report/presentation/widgets/round_metrics_card.dart';
import 'package:event_reg/features/landing/presentation/widgets/participant_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Attendance Report',
          style: TextStyle(color: AppColors.primary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        actions: [
          BlocBuilder<AttendanceReportBloc, AttendanceReportState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: state is AttendanceReportLoading
                    ? null
                    : () {
                        context.read<AttendanceReportBloc>().add(
                          const RefreshAttendanceReportRequested(),
                        );
                      },
              );
            },
          ),
        ],
      ),
      drawer: ParticipantLandingDrawer(),
      body: BlocBuilder<AttendanceReportBloc, AttendanceReportState>(
        builder: (context, state) {
          if (state is AttendanceReportLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your attendance report...'),
                ],
              ),
            );
          }

          if (state is AttendanceReportError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to Load Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AttendanceReportBloc>().add(
                          const FetchAttendanceReportRequested(),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AttendanceReportLoaded) {
            return _buildReportContent(state.report);
          }

          return const Center(child: Text('Welcome to your attendance report'));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch attendance report when page loads
    context.read<AttendanceReportBloc>().add(
      const FetchAttendanceReportRequested(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Attendance Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t attended any sessions yet.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantHeader(AttendanceReport report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  report.participantName.isNotEmpty
                      ? report.participantName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.participantName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Participant ID: ${report.participantId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(AttendanceReport report) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AttendanceReportBloc>().add(
          const RefreshAttendanceReportRequested(),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with participant info
            _buildParticipantHeader(report),
            const SizedBox(height: 24),

            // Aggregated Stats
            AggregatedStatsCard(stats: report.aggregatedStats),
            const SizedBox(height: 16),

            // Attendance Chart
            if (report.attendanceTrend.isNotEmpty) ...[
              AttendanceChartCard(attendanceTrend: report.attendanceTrend),
              const SizedBox(height: 16),
            ],

            // Round Metrics
            if (report.roundMetrics.isNotEmpty) ...[
              RoundMetricsCard(roundMetrics: report.roundMetrics),
              const SizedBox(height: 16),
            ],

            // Location Stats
            if (report.locationStats.isNotEmpty) ...[
              LocationStatsCard(locationStats: report.locationStats),
              const SizedBox(height: 16),
            ],

            // Attendance History
            if (report.attendanceHistory.isNotEmpty) ...[
              AttendanceHistoryCard(
                attendanceHistory: report.attendanceHistory,
              ),
              const SizedBox(height: 16),
            ],

            // Empty state if no attendance history
            if (report.attendanceHistory.isEmpty) _buildEmptyState(),
          ],
        ),
      ),
    );
  }
}
