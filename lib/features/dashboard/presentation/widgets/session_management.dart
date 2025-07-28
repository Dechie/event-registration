import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/session.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class SessionManagementWidget extends StatefulWidget {
  const SessionManagementWidget({super.key});

  @override
  State<SessionManagementWidget> createState() =>
      _SessionManagementWidgetState();
}

class _SessionManagementWidgetState extends State<SessionManagementWidget> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadSessionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SessionsLoaded) {
                return _buildSessionsList(state.sessions);
              }
              return const Center(child: Text('No sessions found'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Session Management',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _addNewSession,
            icon: const Icon(Icons.add),
            label: const Text('Add Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<Session> sessions) {
    if (sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No sessions found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _buildSessionStatusChip(session),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleSessionAction(value, session),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'attendees',
                          child: Row(
                            children: [
                              Icon(Icons.people),
                              SizedBox(width: 8),
                              Text('View Attendees'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: session.isActive ? 'deactivate' : 'activate',
                          child: Row(
                            children: [
                              Icon(
                                session.isActive
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                session.isActive ? 'Deactivate' : 'Activate',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  session.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDateTime(session.startTime)} - ${_formatDateTime(session.endTime)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      session.room ?? "No room",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (session.speaker!= null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Speaker: ${session.speaker}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: session.currentAttendees / session.capacity,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          session.isFull ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${session.currentAttendees}/${session.capacity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionStatusChip(Session session) {
    Color color;
    Color colorWithShade;
    String label;

    if (!session.isActive) {
      color = Colors.grey;
      colorWithShade = Colors.grey.shade800;
      label = 'Inactive';
    } else if (session.isFull) {
      color = Colors.red;
      colorWithShade = Colors.red.shade800;
      label = 'Full';
    } else {
      color = Colors.green;
      colorWithShade = Colors.green.shade800;
      label = 'Active';
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: colorWithShade),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleSessionAction(String action, Session session) {
    switch (action) {
      case 'edit':
        _editSession(session);
        break;
      case 'attendees':
        _viewSessionAttendees(session);
        break;
      case 'activate':
      case 'deactivate':
        _toggleSessionStatus(session);
        break;
      case 'delete':
        _deleteSession(session);
        break;
    }
  }

  void _addNewSession() {
    // Navigate to add session page
  }

  void _editSession(Session session) {
    // Navigate to edit session page
  }

  void _viewSessionAttendees(Session session) {
    // Show attendees dialog or navigate to attendees page
  }

  void _toggleSessionStatus(Session session) {
    // Implement session status toggle
  }

  void _deleteSession(Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to remove "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
