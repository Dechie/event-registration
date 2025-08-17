import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/attendance/presentation/pages/event_list_page.dart';
import 'package:event_reg/features/landing/data/models/event_session.dart';
import 'package:event_reg/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickActionsTab extends StatefulWidget {
  const QuickActionsTab({super.key});

  @override
  State<QuickActionsTab> createState() => _QuickActionsTabState();
}

class _QuickActionsTabState extends State<QuickActionsTab> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome, Admin',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose an action below to get started',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions section
          Text(
            'Quick Actions',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // QR Scanner buttons - Updated to show 4 options
          Expanded(
            child: GridView.count(
              crossAxisCount: 1,
              mainAxisSpacing: 16,
              childAspectRatio: 3.2,
              children: [
                _buildActionCard(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  context,
                  icon: Icons.security,
                  title: 'Security Check',
                  description: 'Verify participant credentials and access',
                  color: Colors.blue,
                  onTap: () => _navigateToScanner(context, 'security'),
                ),
                _buildActionCard(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  context,
                  icon: Icons.fact_check,
                  title: 'Take Attendance',
                  description: 'Scan QR codes to mark attendance for events',
                  color: Colors.green,
                  onTap: () => _navigateToAttendanceFlow(context),
                ),

                // Update your lib/features/admin_dashboard/presentation/widgets/quick_actions_tab.dart
                // Add this action card to the GridView.count children:
                _buildActionCard(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  context,
                  icon: Icons.analytics,
                  title: 'View Reports',
                  description: 'Access attendance reports and analytics',
                  color: Colors.indigo,
                  onTap: () => _navigateToReports(context),
                ),
                _buildActionCard(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  context,
                  icon: Icons.local_offer,
                  title: 'Validate Coupon',
                  description: 'Scan and validate participant coupons',
                  color: Colors.orange,
                  onTap: () => _navigateToScanner(context, 'coupon'),
                ),
                // _buildActionCard(
                //   textTheme: textTheme,
                //   colorScheme: colorScheme,
                //   context,
                //   icon: Icons.info_outline,
                //   title: 'Participant Info',
                //   description: 'View detailed participant information',
                //   color: Colors.purple,
                //   onTap: () => _navigateToScanner(context, 'info'),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
        ),
      ),
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    EventSession session,
    BuildContext dialogContext,
  ) {
    return ListTile(
      leading: Icon(
        Icons.schedule,
        color: session.isActive ? Colors.green : Colors.grey,
      ),
      title: Text(
        session.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: session.isActive ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.description != null)
            Text(
              session.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: session.isActive ? Colors.grey[600] : Colors.grey,
              ),
            ),
          if (session.startTime != null)
            Text(
              '${_formatDateTime(session.startTime!)} - ${session.endTime != null ? _formatTime(session.endTime!) : ''}',
              style: TextStyle(
                fontSize: 11,
                color: session.isActive ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      trailing: session.isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      onTap: session.isActive
          ? () {
              Navigator.of(dialogContext).pop();
              _navigateToScannerWithSession(context, 'attendance', session);
            }
          : null,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToAttendanceFlow(BuildContext context) {
    // Navigate to the event list page with a new AttendanceBloc instance
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<VerificationBloc>(),
          child: const EventListPage(),
        ),
      ),
    );
  }

  void _navigateToReports(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.reportsDashboardPage);
  }

  void _navigateToScanner(BuildContext context, String type) {
    Navigator.pushNamed(
      context,
      RouteNames.qrScannerPage,
      arguments: {'type': type},
    );
  }

  void _navigateToScannerWithSession(
    BuildContext context,
    String type,
    EventSession session,
  ) {
    Navigator.pushNamed(
      context,
      RouteNames.qrScannerPage,
      arguments: {
        'type': type,
        'eventSessionId': session.id,
        'sessionTitle': session.title,
      },
    );
  }
}
