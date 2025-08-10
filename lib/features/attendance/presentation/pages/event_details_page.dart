// lib/features/attendance/presentation/pages/event_details_page.dart

import 'package:event_reg/config/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/attendance_event_model.dart';
import '../../data/models/attendance_location.dart';
import '../../data/models/attendance_session.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class EventDetailsPage extends StatefulWidget {
  final AttendanceEventModel event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Event Details',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AttendanceBloc>().add(
                        LoadEventDetails(widget.event.id),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EventDetailsLoaded) {
            final event = state.event;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Header Card
                  _buildEventHeader(event, textTheme, colorScheme),

                  const SizedBox(height: 20),

                  // Sessions List
                  if (event.sessions.isNotEmpty) ...[
                    Text(
                      'Sessions & Locations',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...event.sessions.map(
                      (session) =>
                          _buildSessionCard(session, textTheme, colorScheme),
                    ),
                  ] else ...[
                    _buildNoSessionsCard(textTheme, colorScheme),
                  ],
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load detailed event information with sessions and locations
    context.read<AttendanceBloc>().add(LoadEventDetails(widget.event.id));
  }

  Widget _buildEventHeader(
    AttendanceEventModel event,
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.event, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEventInfoRow(
              Icons.location_on,
              event.location,
              textTheme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildEventInfoRow(
              Icons.calendar_today,
              _formatDateRange(event.startTime, event.endTime),
              textTheme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildEventInfoRow(
              Icons.schedule,
              '${event.sessionsCount} sessions',
              textTheme,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfoRow(
    IconData icon,
    String text,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTile(
    AttendanceLocation location,
    AttendanceSession session,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: session.isActive
            ? () => _navigateToAttendanceScanner(session, location)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.meeting_room, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Capacity: ${location.capacity}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (session.isActive) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Take Attendance',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.qr_code_scanner, color: Colors.green),
              ] else ...[
                Icon(Icons.block, color: Colors.grey[400]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSessionsCard(TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No Sessions Available',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This event has no sessions configured yet.',
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

  Widget _buildSessionCard(
    AttendanceSession session,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: session.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (session.isActive
                                          ? Colors.green
                                          : Colors.grey)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              session.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: session.isActive
                                    ? Colors.green
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (session.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          session.description!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Locations List
            if (session.locations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Locations (${session.locations.length})',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...session.locations.map(
                (location) => _buildLocationTile(
                  location,
                  session,
                  textTheme,
                  colorScheme,
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'No locations assigned',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime startTime, DateTime endTime) {
    if (startTime.year == endTime.year &&
        startTime.month == endTime.month &&
        startTime.day == endTime.day) {
      return '${startTime.day}/${startTime.month}/${startTime.year}';
    }
    return '${startTime.day}/${startTime.month}/${startTime.year} - ${endTime.day}/${endTime.month}/${endTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToAttendanceScanner(
    AttendanceSession session,
    AttendanceLocation location,
  ) {
    Navigator.pushNamed(
      context,
      RouteNames.qrScannerPage,
      arguments: {
        'type': 'attendance',
        'eventId': widget.event.id,
        'eventSessionId': session.id,
        'sessionTitle': session.title,
        'sessionLocationId': location.id, // New parameter for location
        'locationName': location.name,
      },
    );
  }
}
