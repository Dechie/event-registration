// lib/features/event_registration/presentation/pages/event_details_page.dart
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/event_registration_bloc.dart';
import '../bloc/event_registration_event.dart';
import '../bloc/event_registration_state.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<EventRegistrationBloc, EventRegistrationState>(
        listener: (context, state) {
          if (state is EventRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully registered for event!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to badge generation page
            Navigator.pushNamed(
              context,
              RouteNames.badgePage,
              arguments: {'event': event, 'registration': state.registration},
            );
          } else if (state is EventRegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Banner
                if (event.banner != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(event.banner!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Event Title
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Organization
                if (event.organization != null)
                  Text(
                    'By ${event.organization!.name}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 16),

                // Event Details
                _buildDetailItem(Icons.location_on, 'Location', event.location),
                const SizedBox(height: 12),
                _buildDetailItem(
                  Icons.access_time,
                  'Start Time',
                  _formatDateTime(event.startTime),
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  Icons.access_time_filled,
                  'End Time',
                  _formatDateTime(event.endTime),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),

                // Sessions
                if (event.sessions != null && event.sessions!.isNotEmpty) ...[
                  const Text(
                    'Sessions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...event.sessions!.map(
                    (session) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (session.description != null) ...[
                              const SizedBox(height: 4),
                              Text(session.description!),
                            ],
                            if (session.startTime != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Time: ${_formatDateTime(session.startTime!)}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Registration Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: state is EventRegistrationLoading
                        ? 'Registering...'
                        : 'Register for Event',
                    onPressed: () {
                      if (state is EventRegistrationLoading) {
                        _registerForEvent(context);
                      }
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _registerForEvent(BuildContext context) {
    context.read<EventRegistrationBloc>().add(
      RegisterForEventRequested(eventId: event.id),
    );
  }
}
