// lib/features/event_registration/presentation/pages/registration_status_page.dart
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/badge/presentation/pages/badge_page.dart';
import 'package:event_reg/features/event_registration/data/datasource/event_registration_datasource.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_bloc.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_event.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_state.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/event_registration.dart';

class RegistrationStatusPage extends StatefulWidget {
  final Event event;
  final String eventId;

  const RegistrationStatusPage({
    super.key,
    required this.event,
    required this.eventId,
  });

  @override
  State<RegistrationStatusPage> createState() => _RegistrationStatusPageState();
}

class _RegistrationStatusPageState extends State<RegistrationStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Status'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<EventRegistrationBloc, EventRegistrationState>(
        listener: (context, state) {
          if (state is BadgeGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Badge generated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EventRegistrationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RegistrationStatusLoaded) {
            return _buildStatusView(state.registration);
          } else if (state is BadgeGenerated) {
            return _buildBadgeGeneratedView();
          } else if (state is BadgeLoaded) {
            return _buildBadgeView(state.badge);
          } else if (state is EventRegistrationError) {
            return _buildErrorView(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Check registration status when page loads
    context.read<EventRegistrationBloc>().add(
      CheckRegistrationStatusRequested(eventId: widget.eventId),
    );
  }

  Widget _buildApprovedActions(EventRegistration registration) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Generate Badge',
            onPressed: () async {
              // Fetch full event details first
              try {
                final token = await di.sl<UserDataService>().getAuthToken();
                final response = await di.sl<DioClient>().get(
                  '/my-events/${widget.eventId}',
                  token: token,
                );
                final photoFile = await di
                    .sl<EventRegistrationDataSourceImpl>()
                    .downloadParticipantPhoto(response.data["photo"]);
                final downloadedPhoto = photoFile.path;
                debugPrint("response of get badge: ${response.data}");
                response.data["participant"]?["downloaded_image_path"] =
                    downloadedPhoto;

                // Navigate to badge page with full event details
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BadgePage(
                        event: widget.event,
                        registrationData: response.data,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading badge data: $e')),
                  );
                }
              }
            },
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeGeneratedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Badge Generated!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your event badge has been successfully generated.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'View Badge',
              onPressed: () {
                context.read<EventRegistrationBloc>().add(
                  FetchBadgeRequested(eventId: widget.eventId),
                );
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeView(badge) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Badge Preview Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text("participant"),
                            Text(badge.id),
                            Text("Approved"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.qr_code, size: 80),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Download Badge',
              onPressed: () {
                _downloadBadge(badge);
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Share Badge',
              onPressed: () {
                //_shareBadge(badge);
              },
              backgroundColor: AppColors.secondary,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Retry',
              onPressed: () {
                context.read<EventRegistrationBloc>().add(
                  CheckRegistrationStatusRequested(eventId: widget.eventId),
                );
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Next?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('We\'ll notify you via email'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.badge, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Badge will be available after approval'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Check back here for updates'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Refresh Status',
            onPressed: () {
              context.read<EventRegistrationBloc>().add(
                CheckRegistrationStatusRequested(eventId: widget.eventId),
              );
            },
            backgroundColor: AppColors.secondary,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Contact Organizers',
            onPressed: () {
              // Navigate to contact page or show contact info
              _showContactInfo();
            },
            backgroundColor: AppColors.secondary,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Browse Other Events',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            backgroundColor: AppColors.outline,
            textColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(EventRegistration registration) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    if (registration.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusText = 'Pending Approval';
      statusDescription =
          'Your registration is being reviewed by the event organizers. You will be notified once approved.';
    } else if (registration.isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Approved';
      statusDescription =
          'Congratulations! Your registration has been approved. You can now generate your event badge.';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
      statusDescription =
          'Unfortunately, your registration was not approved. Please contact the organizers for more information.';
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      //border: Border.all(color: statusColor.withOpacity(0.3)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(statusIcon, color: statusColor, size: 48),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusView(EventRegistration registration) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registered on: ${_formatDate(registration.registeredAt)}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Status Section
          Text(
            'Registration Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildStatusCard(registration),
          const SizedBox(height: 24),

          if (registration.isPending) _buildPendingActions(),
          if (registration.isApproved) _buildApprovedActions(registration),
          if (registration.isRejected) _buildRejectedActions(),
        ],
      ),
    );
  }

  void _downloadBadge(badge) {
    // Implement badge download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Badge download feature coming soon!')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showContactInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Organizers'),
        content: const Text(
          'For questions about your registration status, please contact:\n\n'
          'Email: support@eventorg.com\n'
          'Phone: +1 (555) 123-4567',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
