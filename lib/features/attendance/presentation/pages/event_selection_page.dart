import 'package:event_reg/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:event_reg/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/session.dart';
import '../bloc/attendance_state.dart';

class EventSelectionPage extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  final bool isEditMode;
  final List<Session>? currentlySelectedSessions;
  const EventSelectionPage({
    super.key,
    this.profileData,
    this.isEditMode = false,
    this.currentlySelectedSessions,
  });

  @override
  State<EventSelectionPage> createState() => _EventSelectionPageState();
}

class _EventSelectionPageState extends State<EventSelectionPage> {
  List<Session> _selectedSessions = [];
  List<Session> _availableSessions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? "Edit Event Selection" : "Select Events",
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is SessionsRegistrationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Successfully registered for selected session."),
                backgroundColor: Colors.green,
              ),
            );

            if (widget.isEditMode) {
              Navigator.pop(context, true); // return success flag for edit mode
            } else {
              // navigate to success page or dashboard
              Navigator.of(context).pushReplacementNamed(
                "/registration-success",
                arguments: {
                  'profileData': widget.profileData,
                  "selectedSessions": _selectedSessions,
                },
              );
            }
          }
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AvailableSessionsLoadedState) {
              _availableSessions = state.sessions;
            }
            return Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildSessionsList()),
                _buildBottomActions(state),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentlySelectedSessions != null) {
      _selectedSessions = List.from(widget.currentlySelectedSessions!);
    }

    // load available sessions when page initializes
    context.read<AttendanceBloc>().add(const LoadAvailableSessionsEvent());
  }

  Widget _buildBottomActions(AttendanceState state) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedSessions.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Selected: ${_selectedSessions.map((s) => s.title).join(", ")}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (widget.isEditMode) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: state is AttendanceLoadingState
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      state is AttendanceLoadingState ||
                          _selectedSessions.isEmpty
                      ? null
                      : _handleConfirmSelection,
                  child: state is AttendanceLoadingState
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditMode
                              ? "Update Selection"
                              : "Confirm Selection",
                        ),
                ),
              ),
            ],
          ),
          if (_selectedSessions.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Please select at least one session to continue",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditMode
                ? "Update Your Event Selection"
                : "Choose Events to attend",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isEditMode
                ? "Modify your event selections. You can add or remove events."
                : "Select the sessions you want to attend. You can modify this later.",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),

          if (_selectedSessions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "${_selectedSessions.length} session(s) selected",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_availableSessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No sessions available at the moment",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableSessions.length,
      itemBuilder: (context, index) {
        final session = _availableSessions[index];
        final isSelected = _selectedSessions.any((s) => s.id == session.id);
        final isSessionFull = session.currentAttendees >= session.capacity;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: isSessionFull && !isSelected
                ? null
                : () => _toggleSession(session),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSessionFull && !isSelected
                                    ? Colors.grey
                                    : null,
                              ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        )
                      else if (isSessionFull)
                        Icon(Icons.people, color: Colors.red)
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSessionFull && !isSelected
                          ? Colors.grey
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.location,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        "${session.currentAttendees}/${session.capacity} attendees",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSessionFull
                              ? Colors.red.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (isSessionFull && !isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "FULL",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  void _handleConfirmSelection() {
    if (_selectedSessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one sessoin"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.isEditMode) {
      // update session selection
      context.read<AttendanceBloc>().add(
        UpdateSessionSelectionEvent(selectedSessions: _selectedSessions),
      );
    } else {
      // register for sessions
      context.read<AttendanceBloc>().add(
        RegisterForSessionsEvent(
          selectedSessions: _availableSessions,
          profileData: widget.profileData ?? {},
        ),
      );
    }
  }

  void _toggleSession(Session session) {
    setState(() {
      final existingIndex = _selectedSessions.indexWhere(
        (s) => s.id == session.id,
      );
      if (existingIndex >= 0) {
        // means it exists in list
        _selectedSessions.removeAt(existingIndex);
      } else {
        // likely -1, means it doesn't exist in list
        _selectedSessions.add(session);
      }
    });
  }
}
