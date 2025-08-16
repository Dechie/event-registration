// // lib/features/reports/presentation/pages/reports_dashboard_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../attendance/data/models/attendance_event_model.dart';
// import '../../../attendance/presentation/bloc/attendance_bloc.dart';
// import '../../../attendance/presentation/bloc/attendance_event.dart';
// import '../../../attendance/presentation/bloc/attendance_state.dart';

// class ReportsDashboardPage extends StatefulWidget {
//   const ReportsDashboardPage({super.key});

//   @override
//   State<ReportsDashboardPage> createState() => _ReportsDashboardPageState();
// }

// class _ReportsDashboardPageState extends State<ReportsDashboardPage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<AttendanceBloc>().add(const LoadEventsForAttendance());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reports Dashboard'),
//         centerTitle: true,
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               context.read<AttendanceBloc>().add(const LoadEventsForAttendance());
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<AttendanceBloc, AttendanceState>(
//         builder: (context, state) {
//           if (state is AttendanceLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is AttendanceError) {
//             return _buildErrorState(context, state, textTheme, colorScheme);
//           }

//           if (state is EventsLoaded) {
//             return _buildReportsDashboard(context, state.events, textTheme, colorScheme);
//           }

//           return const Center(child: Text('No data available'));
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(
//     BuildContext context,
//     AttendanceError state,
//     TextTheme textTheme,
//     ColorScheme colorScheme,
//   ) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             Text(
//               'Error Loading Events',
//               style: textTheme.headlineSmall?.copyWith(color: Colors.red[700]),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               state.message,
//               textAlign: TextAlign.center,
//               style: textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 context.read<AttendanceBloc>().add(const LoadEventsForAttendance());
//               },
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReportsDashboard(
//     BuildContext context,
//     List<AttendanceEventModel> events,
//     TextTheme textTheme,
//     ColorScheme colorScheme,
//   ) {
//     if (events.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.analytics,
//                 size: 80,
//                 color: colorScheme.onSurfaceVariant,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'No Events Available',
//                 style: textTheme.headlineSmall?.copyWith(
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'There are no events to generate reports for.',
//                 textAlign: TextAlign.center,
//                 style: textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }