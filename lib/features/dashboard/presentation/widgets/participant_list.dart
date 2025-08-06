// import 'package:event_reg/core/shared/models/participant.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../bloc/dashboard_bloc.dart';
// import '../bloc/dashboard_event.dart';
// import '../bloc/dashboard_state.dart';

// class ParticipantsListWidget extends StatefulWidget {
//   const ParticipantsListWidget({super.key});

//   @override
//   State<ParticipantsListWidget> createState() => _ParticipantsListWidgetState();
// }

// class _ParticipantsListWidgetState extends State<ParticipantsListWidget> {
//   final TextEditingController _searchController = TextEditingController();
//   String? _selectedSessionFilter;
//   String? _selectedStatusFilter;
//   List<Participant> _participants = [];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildFilterSection(),
//         Expanded(
//           child: BlocBuilder<DashboardBloc, DashboardState>(
//             builder: (context, state) {
//               if (state is DashboardLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (state is ParticipantsLoaded) {
//                 _participants = state.participants;
//                 return _buildParticipantsList(state.participants);
//               }
//               return const Center(child: Text('No participants found'));
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     context.read<DashboardBloc>().add(LoadParticipantsEvent());
//   }

//   void _applyFilters() {
//     context.read<DashboardBloc>().add(
//       LoadParticipantsEvent(
//         searchQuery: _searchController.text.trim().isEmpty
//             ? null
//             : _searchController.text.trim(),
//         sessionFilter: _selectedSessionFilter,
//         statusFilter: _selectedStatusFilter,
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterSection() {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: 'Search by name, email, or phone',
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) => _applyFilters(),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: _showFilterDialog,
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.filter_list),
//                       SizedBox(width: 4),
//                       Text('Filters'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (_selectedSessionFilter != null || _selectedStatusFilter != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: Wrap(
//                   spacing: 8,
//                   children: [
//                     if (_selectedSessionFilter != null)
//                       Chip(
//                         label: Text('Session: $_selectedSessionFilter'),
//                         onDeleted: () {
//                           setState(() {
//                             _selectedSessionFilter = null;
//                           });
//                           _applyFilters();
//                         },
//                       ),
//                     if (_selectedStatusFilter != null)
//                       Chip(
//                         label: Text('Status: $_selectedStatusFilter'),
//                         onDeleted: () {
//                           setState(() {
//                             _selectedStatusFilter = null;
//                           });
//                           _applyFilters();
//                         },
//                       ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildParticipantsList(List<Participant> participants) {
//     if (participants.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.people_outline, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text('No participants found'),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: participants.length,
//       itemBuilder: (context, index) {
//         final participant = participants[index];
//         return Card(
//           margin: const EdgeInsets.only(bottom: 8),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundImage: participant.photoUrl != null
//                   ? NetworkImage(participant.photoUrl!)
//                   : null,
//               child: participant.photoUrl == null
//                   ? Text(participant.fullName[0].toUpperCase())
//                   : null,
//             ),
//             title: Text(participant.fullName),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(participant.email),
//                 Text(participant.phoneNumber),
//                 Text('${participant.organization} - ${participant.occupation}'),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildStatusChip(participant),
//                 const SizedBox(width: 8),
//                 PopupMenuButton<String>(
//                   onSelected: (value) =>
//                       _handleParticipantAction(value, participant),
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'view',
//                       child: Row(
//                         children: [
//                           Icon(Icons.visibility),
//                           SizedBox(width: 8),
//                           Text('View Details'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'checkin',
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle),
//                           SizedBox(width: 8),
//                           Text('Check In'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'checkout',
//                       child: Row(
//                         children: [
//                           Icon(Icons.cancel),
//                           SizedBox(width: 8),
//                           Text('Check Out'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit),
//                           SizedBox(width: 8),
//                           Text('Edit'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             isThreeLine: true,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusChip(Participant participant) {
//     // This would typically come from the participant data
//     // For now, we'll use a placeholder
//     final isCheckedIn = DateTime.now().hour > 8; // Mock logic

//     return Chip(
//       label: Text(
//         isCheckedIn ? 'Checked In' : 'Not Checked In',
//         style: const TextStyle(fontSize: 12),
//       ),
//       backgroundColor: isCheckedIn
//           ? Colors.green.shade100
//           : Colors.red.shade100,
//       labelStyle: TextStyle(
//         color: isCheckedIn ? Colors.green.shade800 : Colors.red.shade800,
//       ),
//     );
//   }

//   void _editParticipant(Participant participant) {
//     // Navigate to edit participant page
//   }

//   void _handleParticipantAction(String action, Participant participant) {
//     switch (action) {
//       case 'view':
//         _showParticipantDetails(participant);
//         break;
//       case 'checkin':
//         context.read<DashboardBloc>().add(
//           CheckInParticipantEvent(participantId: participant.id),
//         );
//         break;
//       case 'checkout':
//         context.read<DashboardBloc>().add(
//           CheckOutParticipantEvent(participantId: participant.id),
//         );
//         break;
//       case 'edit':
//         _editParticipant(participant);
//         break;
//     }
//   }

//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Filter Participants'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButtonFormField<String>(
//               value: _selectedSessionFilter,
//               decoration: const InputDecoration(
//                 labelText: 'Filter by Session',
//                 border: OutlineInputBorder(),
//               ),
//               items: const [
//                 DropdownMenuItem(value: 'session1', child: Text('Session 1')),
//                 DropdownMenuItem(value: 'session2', child: Text('Session 2')),
//                 DropdownMenuItem(value: 'session3', child: Text('Session 3')),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _selectedSessionFilter = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _selectedStatusFilter,
//               decoration: const InputDecoration(
//                 labelText: 'Filter by Status',
//                 border: OutlineInputBorder(),
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: 'checked_in',
//                   child: Text('Checked In'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'not_checked_in',
//                   child: Text('Not Checked In'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'registered',
//                   child: Text('Registered'),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _selectedStatusFilter = value;
//                 });
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _selectedSessionFilter = null;
//                 _selectedStatusFilter = null;
//               });
//               Navigator.pop(context);
//               _applyFilters();
//             },
//             child: const Text('Clear'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _applyFilters();
//             },
//             child: const Text('Apply'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showParticipantDetails(Participant participant) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(participant.fullName),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildDetailRow('Email', participant.email),
//               _buildDetailRow('Phone', participant.phoneNumber),
//               _buildDetailRow('Gender', participant.gender ?? 'Not specified'),
//               _buildDetailRow(
//                 'Date of Birth',
//                 participant.dateOfBirth?.toString() ?? 'Not specified',
//               ),
//               _buildDetailRow(
//                 'Nationality',
//                 participant.nationality ?? 'Not specified',
//               ),
//               _buildDetailRow('Organization', participant.organization),
//               _buildDetailRow('Occupation', participant.occupation),
//               _buildDetailRow('Industry', participant.industry),
//               _buildDetailRow(
//                 'Experience',
//                 '${participant.yearsOfExperience ?? 0} years',
//               ),
//               _buildDetailRow('Region', participant.region ?? 'Not specified'),
//               _buildDetailRow('City', participant.city ?? 'Not specified'),
//               _buildDetailRow(
//                 'Selected Sessions',
//                 participant.selectedSessions.join(', '),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }
