// lib/features/event_registration/presentation/pages/event_details_page.dart
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:event_reg/features/landing/presentation/widgets/event_info.dart';
import 'package:event_reg/features/landing/presentation/widgets/hero_section.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/event_registration_bloc.dart';
import '../bloc/event_registration_event.dart';
import '../bloc/event_registration_state.dart';
import 'event_registration_status_page.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final UserDataService _userDataService = di.sl<UserDataService>();
  bool _isAuthenticated = false;
  bool _isRegistered = false;
  String? _registrationStatus;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRegistrationStatus();
  }

  Future<void> _checkAuthAndRegistrationStatus() async {
    final isAuth = await _userDataService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
    });

    if (isAuth) {
      // Check if user is registered for this event
      // This would typically come from your bloc or API
      // For now, we'll use a placeholder
      _checkRegistrationStatus();
    }
  }

  Future<void> _checkRegistrationStatus() async {
    // This should be implemented to check actual registration status
    // For now, we'll use a placeholder
    setState(() {
      _isRegistered = false; // This should be checked from your API
      _registrationStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
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

            // Navigate to registration status page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<EventRegistrationBloc>(),
                  child: RegistrationStatusPage(
                    event: widget.event,
                    eventId: widget.event.id,
                  ),
                ),
              ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Registration Status Banner (if registered)
                if (_isAuthenticated && _isRegistered) _buildRegistrationStatusBanner(),

                // Event Banner
                if (widget.event.banner != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.event.banner!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                HeroSection(title: widget.event.title, description: widget.event.description),
                const SizedBox(height: 16),
                EventInfoSection(event: widget.event),

                // Sessions
                if (widget.event.sessions != null && widget.event.sessions!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sessions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.event.sessions!.map(
                          (session) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    session.description ?? 'No description available',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Registration Button or Status
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildRegistrationSection(state),
                ),

                const SizedBox(height: 16),

                // Additional Info Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Registration Process',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1. Submit your registration\n'
                            '2. Wait for organizer approval\n'
                            '3. Receive notification when approved\n'
                            '4. Generate your event badge with QR code\n'
                            '5. Show badge at event entrance',
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegistrationStatusBanner() {
    Color bannerColor;
    IconData bannerIcon;
    String bannerText;

    switch (_registrationStatus?.toLowerCase()) {
      case 'approved':
        bannerColor = Colors.green;
        bannerIcon = Icons.check_circle;
        bannerText = 'Registration Approved!';
        break;
      case 'rejected':
        bannerColor = Colors.red;
        bannerIcon = Icons.cancel;
        bannerText = 'Registration Rejected';
        break;
      case 'pending':
      default:
        bannerColor = Colors.orange;
        bannerIcon = Icons.pending;
        bannerText = 'Registration Pending Approval';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: bannerColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bannerText,
              style: TextStyle(
                color: bannerColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationSection(EventRegistrationState state) {
    if (!_isAuthenticated) {
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: 'Login to Register',
          onPressed: () {
            Navigator.pushNamed(context, RouteNames.participantLoginPage);
          },
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        ),
      );
    }

    if (_isRegistered) {
      // User is registered - show status-based button
      switch (_registrationStatus?.toLowerCase()) {
        case 'approved':
          return SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'View Badge',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteNames.badgePage,
                  arguments: {
                    "event": widget.event,
                    "registrationData": {"status": _registrationStatus},
                  },
                );
              },
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
          );
        case 'rejected':
          return SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Registration Rejected',
              onPressed: () {
                // Show rejection message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your registration was rejected. Please contact the event organizer.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
          );
        case 'pending':
        default:
          return SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Registration Pending',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteNames.eventRegistrationStatusPage,
                  arguments: {"event": widget.event},
                );
              },
              backgroundColor: Colors.orange,
              textColor: Colors.white,
            ),
          );
      }
    }

    // Not registered - show register button
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: state is EventRegistrationLoading
            ? 'Registering...'
            : 'Register for Event',
        onPressed: () {
          if (state is! EventRegistrationLoading) {
            _registerForEvent(context);
          }
        },
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _registerForEvent(BuildContext context) {
    context.read<EventRegistrationBloc>().add(
      RegisterForEventRequested(eventId: widget.event.id),
    );
  }
}
