import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantLandingDrawer extends StatelessWidget {
  final int selectedTile;
  const ParticipantLandingDrawer({super.key, required this.selectedTile});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section with Logo and Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.event,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // App Title
                const Text(
                  'EventHub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Participant Portal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Events Item (Current Page)
                ListTile(
                  leading: Icon(
                    Icons.event_available,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Events',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  selected: selectedTile == 1,
                  selectedTileColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(RouteNames.landingPage);
                  },
                ),

                // // My Events
                // ListTile(
                //   leading: Icon(Icons.bookmark, color: Colors.grey[600]),
                //   title: Text(
                //     'My Events',
                //     style: TextStyle(
                //       color: Colors.grey[600],
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.pushNamed(context, RouteNames.myEventsPage);
                //   },
                // ),

                // Attendance Report - NEW
                ListTile(
                  leading: Icon(
                    Icons.assessment,
                    color: Theme.of(context).primaryColor,
                  ),

                  selected: selectedTile == 2,
                  selectedTileColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  title: const Text(
                    'My Attendance Report',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(RouteNames.attendanceReportPage);
                  },
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.workspace_premium,
                //     color: Theme.of(context).primaryColor,
                //   ),
                //   selected: selectedTile == 3,
                //   selectedTileColor: Theme.of(
                //     context,
                //   ).primaryColor.withValues(alpha: 0.1),
                //   title: const Text(
                //     'My Certificates',
                //     style: TextStyle(fontWeight: FontWeight.w500),
                //   ),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.of(
                //       context,
                //     ).pushReplacementNamed(RouteNames.myCertificatesPage);
                //   },
                // ),

                // // Profile
                // ListTile(
                //   leading: Icon(Icons.person, color: Colors.grey[600]),
                //   title: Text(
                //     'Profile',
                //     style: TextStyle(
                //       color: Colors.grey[600],
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                //   onTap: () {
                //     Navigator.pop(context);
                //     // TODO: Navigate to Profile page when implemented
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('Profile - Coming Soon!')),
                //     );
                //   },
                // ),
                const Divider(height: 32, indent: 16, endIndent: 16),

                // Logout Item
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoggingOut = state is AuthLoadingState;

                    return ListTile(
                      leading: isLoggingOut
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red[400],
                              ),
                            )
                          : Icon(Icons.logout, color: Colors.red[400]),
                      title: Text(
                        isLoggingOut ? 'Logging out...' : 'Logout',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: isLoggingOut
                          ? null
                          : () {
                              _showLogoutDialog(context);
                            },
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog first
                // Trigger logout event
                context.read<AuthBloc>().add(LogoutEvent());
                // Don't close the drawer here - let the BlocListener handle navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
