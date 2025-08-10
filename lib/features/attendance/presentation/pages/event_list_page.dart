import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/attendance/data/models/attendance_event_model.dart';
import 'package:event_reg/features/attendance/data/models/attendance_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import 'room_list_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final Map<String, bool> _expandedEvents = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
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
                    'Error Loading Events',
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
                        LoadEventsForAttendance(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Events Available',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'There are no events available for attendance tracking.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fact_check,
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Event & Session',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choose an event and session to take attendance for',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Events list
                  Text(
                    'Available Events',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: state.events.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = state.events[index];

                        return _buildEventCard(
                          context,
                          event,
                          textTheme,
                          colorScheme,
                        );
                      },
                    ),
                  ),
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
    // Load events when page initializes
    context.read<AttendanceBloc>().add(LoadEventsForAttendance());
  }

  Widget _buildEventCard(
    BuildContext context,
    AttendanceEventModel event,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteNames.eventDetailsPage,
            arguments: {'event': event, 'bloc': context.read<AttendanceBloc>()},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: _getEventStatusColor(event.isActive),
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
                            event.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventStatusColor(
                              event.isActive,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getEventStatusText(event.isActive),
                            style: TextStyle(
                              color: _getEventStatusColor(event.isActive),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (event.description != null) ...[
                      Text(
                        event.description!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event.startTime),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.sessionsCount} sessions',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  Widget _buildSessionCard(
    BuildContext context,
    AttendanceSession session,
    AttendanceEventModel event,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: session.isActive
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<AttendanceBloc>(),
                      child: RoomListPage(event: event, session: session),
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: _getSessionStatusColor(session.isActive),
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
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: session.isActive ? null : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSessionStatusColor(
                              session.isActive,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getSessionStatusText(session.isActive),
                            style: TextStyle(
                              color: _getSessionStatusColor(session.isActive),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (session.description != null) ...[
                      Text(
                        session.description!,
                        style: textTheme.bodySmall?.copyWith(
                          color: session.isActive
                              ? colorScheme.onSurfaceVariant
                              : Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: session.isActive
                              ? colorScheme.onSurfaceVariant
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: session.isActive
                                ? colorScheme.onSurfaceVariant
                                : Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.meeting_room,
                          size: 12,
                          color: session.isActive
                              ? colorScheme.onSurfaceVariant
                              : Colors.grey[500],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (session.isActive) ...[
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 14,
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
    AttendanceEventModel event,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final sessions = event.sessions;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessions (${sessions.length})',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final session = sessions[index];

              return _buildSessionCard(
                context,
                session,
                event,
                textTheme,
                colorScheme,
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getEventStatusColor(bool isActive) {
    if (isActive) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String _getEventStatusText(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }

  Color _getSessionStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.grey;
  }

  String _getSessionStatusText(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }

  void _toggleEventExpansion(String eventId) {
    setState(() {
      _expandedEvents[eventId] = !(_expandedEvents[eventId] ?? false);
    });
  }
}
