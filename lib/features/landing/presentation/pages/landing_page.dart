// lib/features/landing/presentation/pages/updated_landing_page.dart
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_bloc.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_event.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_state.dart';
import 'package:event_reg/features/event_registration/presentation/pages/event_details_page.dart';
import 'package:event_reg/features/event_registration/presentation/pages/event_registration_status_page.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:event_reg/features/landing/presentation/widgets/participant_drawer.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdatedLandingPage extends StatefulWidget {
  const UpdatedLandingPage({super.key});

  @override
  State<UpdatedLandingPage> createState() => _UpdatedLandingPageState();
}

class _UpdatedLandingPageState extends State<UpdatedLandingPage> {
  final UserDataService _userDataService = di.sl<UserDataService>();
  bool _isAuthenticated = false;

  List<Event> _availableEvents = [];

  List<Event> _registeredEvents = [];

  final Map<String, String> _registrationStatuses = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Events")),
      drawer: ParticipantLandingDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<EventRegistrationBloc>().add(
            FetchAvailableEventsRequested(),
          );
          await _checkAuthStatus();
          if (_isAuthenticated && context.mounted) {
            context.read<EventRegistrationBloc>().add(FetchMyEventsRequested());
          }
          // Clear cached statuses to refresh them
          _registrationStatuses.clear();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<EventRegistrationBloc, EventRegistrationState>(
                builder: (context, state) {
                  if (state is EventRegistrationLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AvailableEventsLoaded) {
                    _availableEvents = state.events;

                    return _buildEventsSection();
                  } else if (state is MyEventsLoaded) {
                    _registeredEvents = state.events;

                    return _buildEventsSection();
                  } else if (state is EventRegistrationError) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load events',
                            style: TextStyle(
                              fontSize: 18,
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
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Retry',
                            onPressed: () {
                              context.read<EventRegistrationBloc>().add(
                                FetchAvailableEventsRequested(),
                              );
                              if (_isAuthenticated) {
                                context.read<EventRegistrationBloc>().add(
                                  FetchMyEventsRequested(),
                                );
                              }
                            },
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildEventsSection();
                },
              ),

              // Event Highlights
              //const EventHighlightsCard(),

              // Action Buttons Section
              //_buildActionButtons(),

              // Admin Access (Hidden/Small Link)
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 32.0),
              //   child: TextButton(
              //     onPressed: () {
              //       Navigator.pushNamed(context, RouteNames.adminLoginPage);
              //     },
              //     child: Text(
              //       'Admin Access',
              //       style: TextStyle(
              //         color: AppColors.textSecondary,
              //         fontSize: 12,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    // Fetch available events when page loads
    context.read<EventRegistrationBloc>().add(FetchAvailableEventsRequested());
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (_isAuthenticated) ...[
            // User is authenticated - show dashboard and my events
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'My Dashboard',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.participantDashboardPage,
                  );
                },
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'My Registered Events',
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.myEventsPage);
                },
                backgroundColor: AppColors.secondary,
                textColor: Colors.white,
              ),
            ),
          ] else ...[
            // User is not authenticated - show registration and login
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Register Now',
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.registrationPage);
                },
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Already Registered? Sign In',
                onPressed: () {
                  _showRoleSelectionDialog();
                },
                backgroundColor: Colors.transparent,
                textColor: AppColors.primary,
                borderColor: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Quick Access Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Event Agenda',
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.eventAgendaPage);
                  },
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Contact Us',
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.contactPage);
                  },
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventActionButton(Event event) {
    // Check if user is registered for this event
    final isRegistered = _registeredEvents.any((e) => e.id == event.id);

    if (!_isAuthenticated) {
      // Not authenticated - show "View Details"
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: 'View Details',
          onPressed: () => _navigateToEventDetails(event),
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        ),
      );
    }

    if (!isRegistered) {
      // Not registered - show "View Details & Register"
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: 'View Details & Register',
          onPressed: () => _navigateToEventDetails(event),
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        ),
      );
    }

    // Registered - show status-based button
    return FutureBuilder<String?>(
      future: _getRegistrationStatusForEvent(event.id),
      builder: (context, snapshot) {
        final status = snapshot.data ?? 'pending';

        String buttonText;
        Color buttonColor;

        switch (status.toLowerCase()) {
          case 'approved':
            buttonText = 'View Badge';
            buttonColor = Colors.green;
            break;
          case 'rejected':
            buttonText = 'Registration Rejected';
            buttonColor = Colors.red;
            break;
          case 'pending':
          default:
            buttonText = 'Registration Pending';
            buttonColor = Colors.orange;
            break;
        }

        return SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: buttonText,
            onPressed: () {
              if (status.toLowerCase() == 'approved') {
                // Navigate to badge page
                Navigator.pushNamed(
                  context,
                  RouteNames.badgePage,
                  arguments: {
                    "event": event,
                    "registrationData": {"status": status},
                  },
                );
              } else {
                // Navigate to registration status page
                Navigator.pushNamed(
                  context,
                  RouteNames.eventRegistrationStatusPage,
                  arguments: {"event": event},
                );
              }
            },
            backgroundColor: buttonColor,
            textColor: Colors.white,
          ),
        );
      },
    );
  }

  // In lib/features/landing/presentation/pages/landing_page.dart

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Banner
            if (event.banner != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  event.banner!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 160,
                    color: AppColors.background,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Organization
                  if (event.organization != null)
                    Text(
                      'By ${event.organization!.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Event Details
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
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
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(event.startTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description Preview
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Action Button with Registration Status
                  _buildEventActionButton(event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // In lib/features/landing/presentation/pages/landing_page.dart

  Widget _buildEventsSection() {
    // This logic is correct. It separates registered from unregistered events.
    final registeredEventIds = _registeredEvents.map((e) => e.id).toSet();
    final unregisteredEvents = _availableEvents
        .where((event) => !registeredEventIds.contains(event.id))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registered Events Section
          if (_isAuthenticated && _registeredEvents.isNotEmpty) ...[
            // ... your "My Registered Events" title ...
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _registeredEvents.length,
              itemBuilder: (context, index) {
                final event = _registeredEvents[index];
                // ✅ Correct: Using the card that checks status

                return _buildRegisteredEventCard(event);
              },
            ),
            const SizedBox(height: 32),
          ],

          // Available Events Section
          // ... your "Available Events" title ...
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: unregisteredEvents.length,
            itemBuilder: (context, index) {
              final event = unregisteredEvents[index];
              // ✅ Correct: Using the simplified card that does NOT check status

              return _buildEventCard(event);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredEventButton(Event event) {
    return FutureBuilder<String?>(
      future: _getRegistrationStatusForEvent(event.id),
      builder: (context, snapshot) {
        final status = snapshot.data ?? 'pending';

        String buttonText;
        Color buttonColor;

        switch (status.toLowerCase()) {
          case 'approved':
            buttonText = 'View Badge';
            buttonColor = Colors.green;
            break;
          case 'rejected':
            buttonText = 'View Details';
            buttonColor = Colors.red;
            break;
          case 'pending':
          default:
            buttonText = 'View Status';
            buttonColor = Colors.orange;
            break;
        }

        return CustomButton(
          text: buttonText,
          onPressed: () => _navigateToRegistrationStatus(event),
          backgroundColor: buttonColor,
          textColor: Colors.white,
        );
      },
    );
  }

  Widget _buildRegisteredEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToRegistrationStatus(event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Banner
            if (event.banner != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      event.banner!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 160,
                        color: AppColors.background,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    // Registration status badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildStatusBadge(event.id),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Organization
                  if (event.organization != null)
                    Text(
                      'By ${event.organization!.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Event Details
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
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
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(event.startTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description Preview
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Status-based Action Button
                  SizedBox(
                    width: double.infinity,
                    child: _buildRegisteredEventButton(event),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Add helper methods:
  Widget _buildStatusBadge(String eventId) {
    return FutureBuilder<String?>(
      future: _getRegistrationStatusForEvent(eventId),
      builder: (context, snapshot) {
        final status = snapshot.data ?? 'pending';

        Color badgeColor;
        String statusText;
        IconData statusIcon;

        switch (status.toLowerCase()) {
          case 'approved':
            badgeColor = Colors.green;
            statusText = 'Approved';
            statusIcon = Icons.check_circle;
            break;
          case 'rejected':
            badgeColor = Colors.red;
            statusText = 'Rejected';
            statusIcon = Icons.cancel;
            break;
          case 'pending':
          default:
            badgeColor = Colors.orange;
            statusText = 'Pending';
            statusIcon = Icons.hourglass_empty;
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkAuthStatus() async {
    debugPrint("in landing page: checking auth status.");
    final isAuth = await _userDataService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
    });

    // If authenticated, also fetch registered events
    if (isAuth && mounted) {
      context.read<EventRegistrationBloc>().add(FetchMyEventsRequested());
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  Future<String?> _getRegistrationStatusForEvent(String eventId) async {
    // Check if we already have the status cached
    if (_registrationStatuses.containsKey(eventId)) {
      return _registrationStatuses[eventId];
    }

    try {
      final token = await _userDataService.getAuthToken();
      final response = await di.sl<DioClient>().get(
        '/my-events/$eventId',
        token: token,
      );
      final status = response.data['participant']?['is_approved'] ?? 'pending';

      // Cache the status
      _registrationStatuses[eventId] = status;
      return status;
    } catch (e) {
      return 'pending';
    }
  }

  Future<String?> _getUserRegistrationStatus(String eventId) async {
    if (!_isAuthenticated) return null;

    try {
      final bloc = context.read<EventRegistrationBloc>();
      // You'll need to add a new event for this
      bloc.add(CheckRegistrationStatusRequested(eventId: eventId));

      // Wait for the response and return status
      await for (final state in bloc.stream) {
        if (state is RegistrationStatusLoaded) {
          return state.registration.status;
        } else if (state is EventRegistrationError) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void _navigateToEventDetails(Event event) {
    if (_isAuthenticated) {
      // Navigate to event details page for registration
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<EventRegistrationBloc>(),
            child: EventDetailsPage(event: event),
          ),
        ),
      );
    } else {
      // Show dialog to prompt login/registration
      _showAuthRequiredDialog(event);
    }
  }

  void _navigateToRegistrationStatus(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<EventRegistrationBloc>(),
          child: RegistrationStatusPage(event: event, eventId: event.id),
        ),
      ),
    );
  }

  void _showAuthRequiredDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text(
          'You need to register or sign in to view event details and register for events.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.participantLoginPage);
            },
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.registrationPage);
            },
            child: Text('Register', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Role'),
        content: const Text('Please select your role to sign in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.participantLoginPage);
            },
            child: const Text('Participant'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.adminLoginPage);
            },
            child: const Text('Admin'),
          ),
        ],
      ),
    );
  }
}
