// lib/features/landing/presentation/pages/updated_landing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_bloc.dart';
import 'package:event_reg/features/event_registration/presentation/pages/event_details_page.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:event_reg/injection_container.dart' as di;

import '../widgets/event_highlights.dart';
import '../widgets/event_info.dart';
import '../widgets/hero_section.dart';

class UpdatedLandingPage extends StatefulWidget {
  const UpdatedLandingPage({super.key});

  @override
  State<UpdatedLandingPage> createState() => _UpdatedLandingPageState();
}

class _UpdatedLandingPageState extends State<UpdatedLandingPage> {
  final UserDataService _userDataService = di.sl<UserDataService>();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    // Fetch available events when page loads
    context.read<EventRegistrationBloc>().add(FetchAvailableEventsRequested());
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = await _userDataService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<EventRegistrationBloc>().add(FetchAvailableEventsRequested());
          await _checkAuthStatus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section with App Bar
              const HeroSection(),

              // Event Information Section
              const EventInfoSection(),

              // Available Events Section
              BlocBuilder<EventRegistrationBloc, EventRegistrationState>(
                builder: (context, state) {
                  if (state is EventRegistrationLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AvailableEventsLoaded) {
                    return _buildEventsSection(state.events);
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
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Retry',
                            onPressed: () {
                              context.read<EventRegistrationBloc>().add(
                                FetchAvailableEventsRequested(),
                              );
                            },
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Event Highlights
              const EventHighlightsCard(),

              // Action Buttons Section
              _buildActionButtons(),

              // Admin Access (Hidden/Small Link)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.adminLoginPage);
                  },
                  child: Text(
                    'Admin Access',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection(List<Event> events) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Events Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for upcoming events',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Events',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Banner
            if (event.banner != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.banner!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 160,
                    color: AppColors.backgroundSecondary,
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

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _isAuthenticated ? 'View Details & Register' : 'View Details',
                      onPressed: () => _navigateToEventDetails(event),
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  Navigator.pushNamed(context, RouteNames.participantDashboardPage);
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
                  Navigator.pushNamed(context, RouteNames.participantLoginPage);
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
            child: Text(
              'Register',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}

// lib/features/event_registration/presentation/pages/my_events_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import '../bloc/event_registration_bloc.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventRegistrationBloc>().add(FetchMyEventsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Registered Events'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<EventRegistrationBloc, EventRegistrationState>(
        builder: (context, state) {
          if (state is EventRegistrationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MyEventsLoaded) {
            if (state.events.isEmpty) {
              return _buildEmptyState();
            }
            return _buildEventsList(state.events);
          } else if (state is EventRegistrationError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Registered Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t registered for any events yet. Browse available events and register now!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Browse Events',
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.landingPage);
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Events',
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
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Retry',
              onPressed: () {
                context.read<EventRegistrationBloc>().add(FetchMyEventsRequested());
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EventRegistrationBloc>().add(FetchMyEventsRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(