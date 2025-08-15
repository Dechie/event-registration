// import 'package:flutter/material.dart';

// import '../../data/models/dashboard_stats.dart';

// class DashboardStatsCard extends StatelessWidget {
//   final DashboardStats stats;

//   const DashboardStatsCard({super.key, required this.stats});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'Total Registrants',
//                 stats.totalRegistrants.toString(),
//                 Icons.people,
//                 Colors.blue,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'Checked In',
//                 stats.checkedInAttendees.toString(),
//                 Icons.check_circle,
//                 Colors.green,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'No Shows',
//                 stats.noShows.toString(),
//                 Icons.person_off,
//                 Colors.orange,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'Attendance Rate',
//                 '${((stats.checkedInAttendees / stats.totalRegistrants) * 100).toStringAsFixed(1)}%',
//                 Icons.trending_up,
//                 Colors.purple,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.event_seat, color: Colors.indigo),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Session Attendance',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 if (stats.sessionAttendance.isEmpty)
//                   const Text('No session data available')
//                 else
//                   ...stats.sessionAttendance.entries.map(
//                     (entry) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               entry.key,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.indigo.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               '${entry.value}',
//                               style: TextStyle(
//                                 color: Colors.indigo.shade700,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Last updated: ${_formatDateTime(stats.lastUpdated)}',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodySmall?.copyWith(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(
//     BuildContext context,
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: color, size: 24),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withValues(alpha:0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: color, size: 20),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               value,
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }
// }
