// lib/features/admin_dashboard/presentation/widgets/dashboard_stats_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/admin_dashboard_data.dart';
import '../bloc/admin_dashboard_bloc.dart';
import '../bloc/admin_dashboard_event.dart';
import '../bloc/admin_dashboard_state.dart';

class DashboardStatsTab extends StatelessWidget {
  const DashboardStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AdminDashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminDashboardBloc>().add(LoadDashboardData());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is AdminDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(RefreshDashboardData());
            },
            child: _buildDashboardContent(context, state.dashboardData),
          );
        }
        return const Center(child: Text('Initialize dashboard data'));
      },
    );
  }

  Widget _buildAttendanceBySession(
    BuildContext context,
    List<AttendanceBySession> sessions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance by Session',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: sessions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No session data available')),
                )
              : Column(
                  children: sessions.map((session) {
                    return ListTile(
                      leading: Icon(
                        Icons.schedule,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        session.session,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(_formatDateTime(session.startTime)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${session.attended} attended',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context, AdminDashboardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats Cards
          _buildOverviewStats(context, data),
          const SizedBox(height: 24),

          // Upcoming Events
          _buildUpcomingEvents(context, data.upcomingEvents),
          const SizedBox(height: 24),

          // Attendance by Session
          _buildAttendanceBySession(context, data.attendanceBySession),
          const SizedBox(height: 24),

          // Demographics Section
          Row(
            children: [
              Expanded(child: _buildGenderStats(context, data.genderStats)),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: _buildOccupationStats(context, data.occupationStats),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRow(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count (${percentage.toStringAsFixed(1)}%)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGenderStats(BuildContext context, GenderStats stats) {
    final total = stats.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender Distribution',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildGenderRow(
                  context,
                  'Male',
                  stats.male,
                  total,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildGenderRow(
                  context,
                  'Female',
                  stats.female,
                  total,
                  Colors.pink,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildOccupationStats(
  //   BuildContext context,
  //   Map<String, int> occupations,
  // ) {
  //   final sortedOccupations = occupations.entries.toList()
  //     ..sort((a, b) => b.value.compareTo(a.value));

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Top Occupations',
  //         style: Theme.of(
  //           context,
  //         ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 16),
  //       Card(
  //         elevation: 2,
  //         child: occupations.isEmpty
  //             ? const Padding(
  //                 padding: EdgeInsets.all(24.0),
  //                 child: Center(child: Text('No occupation data')),
  //               )
  //             : Padding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 child: Column(
  //                   children: sortedOccupations.take(5).map((entry) {
  //                     return Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 4.0),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: Text(
  //                               entry.key,
  //                               style: const TextStyle(
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                           Container(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 8,
  //                               vertical: 4,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               color: Theme.of(
  //                                 context,
  //                               ).primaryColor.withOpacity(0.1),
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                             child: Text(
  //                               entry.value.toString(),
  //                               style: TextStyle(
  //                                 color: Theme.of(context).primaryColor,
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildOverviewStats(BuildContext context, AdminDashboardData data) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.95,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              'Events',
              data.eventsCount.toString(),
              Icons.event,
              colorScheme.primary,
            ),
            _buildStatCard(
              context,
              'Sessions',
              data.sessionsCount.toString(),
              Icons.schedule,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'Participants',
              data.participantsCount.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Attendance Rate',
              '${data.attendanceRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              'Active Coupons',
              data.activeCouponsCount.toString(),
              Icons.local_offer,
              Colors.purple,
            ),
            _buildStatCard(
              context,
              'Pending Approvals',
              data.pendingApprovalsCount.toString(),
              Icons.pending_actions,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(
    BuildContext context,
    List<UpcomingEvent> events,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: events.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No upcoming events')),
                )
              : Column(
                  children: events.asMap().entries.map((entry) {
                    final index = entry.key;
                    final event = entry.value;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(_formatDateTime(event.startTime)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);

      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }
}
