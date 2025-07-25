import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/event_info_card.dart';
import '../widgets/participant_info_card.dart';
import '../widgets/qr_code_card.dart';
import '../widgets/session_list_card.dart';

class ParticipantDashboardPage extends StatefulWidget {
  final String email;

  const ParticipantDashboardPage({super.key, required this.email});

  @override
  State<ParticipantDashboardPage> createState() =>
      _ParticipantDashboardPageState();
}

class _ParticipantDashboardPageState extends State<ParticipantDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(
                LoadParticipantDashboardEvent(email: widget.email),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'download':
                  _downloadConfirmation();
                  break;
                case 'edit':
                  _editProfile();
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Download Confirmation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'My Info'),
            Tab(icon: Icon(Icons.event), text: 'My Sessions'),
            Tab(icon: Icon(Icons.qr_code), text: 'My Ticket'),
          ],
        ),
      ),
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ConfirmationPdfReady) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Confirmation PDF is ready for download'),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () {
                    // Open PDF viewer or browser
                  },
                ),
              ),
            );
          } else if (state is ParticipantInfoUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.success
                      ? 'Profile updated successfully'
                      : 'Failed to update profile',
                ),
                backgroundColor: state.success ? Colors.green : Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParticipantDashboardLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildMyInfoTab(state.dashboard),
                  _buildMySessionsTab(state.dashboard),
                  _buildMyTicketTab(state.dashboard),
                ],
              );
            }
            return const Center(
              child: Text('Unable to load dashboard. Please try again.'),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load participant dashboard data
    context.read<DashboardBloc>().add(
      LoadParticipantDashboardEvent(email: widget.email),
    );
  }

  Widget _buildMyInfoTab(dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ParticipantInfoCard(
            participant: dashboard.participant,
            canEdit: dashboard.canEditInfo,
            onEdit: _editProfile,
          ),
          const SizedBox(height: 16),
          EventInfoCard(eventInfo: dashboard.eventInfo),
        ],
      ),
    );
  }

  Widget _buildMySessionsTab(dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SessionListCard(
        sessions: dashboard.selectedSessions,
        eventInfo: dashboard.eventInfo,
      ),
    );
  }

  Widget _buildMyTicketTab(dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          QRCodeCard(
            qrCode: dashboard.qrCode,
            participant: dashboard.participant,
            confirmationStatus: dashboard.confirmationStatus,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Present this QR code at the event entrance for check-in',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadConfirmation,
                          icon: const Icon(Icons.download),
                          label: const Text('Download PDF'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareTicket,
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadConfirmation() {
    // Implementation will depend on the participant ID
    // For now, we'll use a placeholder
    context.read<DashboardBloc>().add(
      DownloadConfirmationPdfEvent(participantId: 'participant_id'),
    );
  }

  void _editProfile() {
    // Navigate to edit profile page
  }

  void _logout() {
    // Implement logout functionality
  }

  void _shareTicket() {
    // Implement share functionality
  }
}
