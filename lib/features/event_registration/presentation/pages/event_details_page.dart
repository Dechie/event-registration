// // lib/features/event_registration/presentation/pages/event_details_page.dart
// import 'package:event_reg/config/themes/app_colors.dart';
// import 'package:event_reg/core/shared/widgets/custom_button.dart';
// import 'package:event_reg/features/landing/data/models/event.dart';
// import 'package:event_reg/features/landing/presentation/widgets/event_info.dart';
// import 'package:event_reg/features/landing/presentation/widgets/hero_section.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../bloc/event_registration_bloc.dart';
// import '../bloc/event_registration_event.dart';
// import '../bloc/event_registration_state.dart';
// import 'event_registration_status_page.dart';

// class EventDetailsPage extends StatelessWidget {
//   final Event event;

//   const EventDetailsPage({super.key, required this.event});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(event.title),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: BlocConsumer<EventRegistrationBloc, EventRegistrationState>(
//         listener: (context, state) {
//           if (state is EventRegistrationSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Successfully registered for event!'),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             // Navigate to registration status page instead of badge page
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => BlocProvider.value(
//                   value: context.read<EventRegistrationBloc>(),
//                   child: RegistrationStatusPage(
//                     event: event,
//                     eventId: event.id,
//                   ),
//                 ),
//               ),
//             );
//           } else if (state is EventRegistrationError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Event Banner
//                 if (event.banner != null)
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       image: DecorationImage(
//                         image: NetworkImage(event.banner!),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 HeroSection(title: event.title, description: event.description),
//                 const SizedBox(height: 16),
//                 EventInfoSection(event: event),

//                 // Sessions
//                 if (event.sessions != null && event.sessions!.isNotEmpty) ...[
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Sessions',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ...event.sessions!.map(
//                           (session) => Card(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             child: Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     session.title,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   if (session.description != null) ...[
//                                     const SizedBox(height: 4),
//                                     Text(session.description!),
//                                   ],
//                                   if (session.startTime != null) ...[
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Time: ${_formatDateTime(session.startTime!)}',
//                                       style: TextStyle(
//                                         color: AppColors.textSecondary,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],

//                 // Registration Button
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: CustomButton(
//                       text: state is EventRegistrationLoading
//                           ? 'Registering...'
//                           : 'Register for Event',
//                       onPressed: () {
//                         if (state is! EventRegistrationLoading) {
//                           _registerForEvent(context);
//                         }
//                       },
//                       backgroundColor: AppColors.primary,
//                       textColor: Colors.white,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Additional Info Card
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Card(
//                     color: AppColors.primary.withOpacity(0.1),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 color: AppColors.primary,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Registration Process',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.primary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           const Text(
//                             '1. Submit your registration\n'
//                             '2. Wait for organizer approval\n'
//                             '3. Receive notification when approved\n'
//                             '4. Generate your event badge with QR code\n'
//                             '5. Show badge at event entrance',
//                             style: TextStyle(height: 1.5),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 32),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }

//   void _registerForEvent(BuildContext context) {
//     context.read<EventRegistrationBloc>().add(
//       RegisterForEventRequested(eventId: event.id),
//     );
//   }
// }
// lib/features/event_registration/presentation/pages/event_details_page.dart

// Add this import to access ParticipantBadge
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/event_registration/data/models/event_registration.dart';
import 'package:event_reg/features/event_registration/data/models/participant_badge.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../landing/presentation/widgets/event_info.dart';
import '../../../landing/presentation/widgets/hero_section.dart';
import '../bloc/event_registration_bloc.dart';
import '../bloc/event_registration_state.dart';
import 'event_registration_status_page.dart';

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
          // This part of the code remains the same, but it will be bypassed
          // by the new `onPressed` logic below.
          if (state is EventRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully registered for event!'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<EventRegistrationBloc>(),
                  child: RegistrationStatusPage(
                    event: event,
                    eventId: event.id,
                    dummyRegistration: EventRegistration(
                      id: "1",
                      eventId: event.id,
                      participantId: "1",
                      status: "approved",
                      badge: ParticipantBadge(
                        id: "1234",
                        participantId: "1",
                        qrCode: 'DUMMY_QR_CODE',
                        eventId: '12345', // Replace with participant ID
                        //organization: 'Example Corp', // Replace with organization name
                        generatedAt: DateTime.now(),
                      ),
                      registeredAt: DateTime.now(),
                    ),
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
                HeroSection(title: event.title, description: event.description),
                const SizedBox(height: 16),
                EventInfoSection(event: event),

                // Sessions
                if (event.sessions != null && event.sessions!.isNotEmpty) ...[
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Registration Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: state is EventRegistrationLoading
                          ? 'Registering...'
                          : 'Register for Event',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: context.read<EventRegistrationBloc>(),
                              child:RegistrationStatusPage(
                                event: event,
                                eventId: event.id,
                                // Pass dummy data to the status page
                                dummyRegistration:  EventRegistration(
                                  id: "1",
                                  eventId: event.id,
                                  participantId: "1",
                                  status: "approved",
                                  badge: ParticipantBadge(
                                    id: "1234",
                                    participantId: "1",
                                    qrCode: 'DUMMY_QR_CODE',
                                    eventId:
                                        '12345', // Replace with participant ID
                                    //organization: 'Example Corp', // Replace with organization name
                                    generatedAt: DateTime.now(),
                                  ),
                                  registeredAt: DateTime.now(),
                                ),
                             ), 
                            ),
                          ),
                        );
                        if (state is! EventRegistrationLoading) {
                          // Bypass the Bloc and navigate directly with dummy data
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<EventRegistrationBloc>(),
                                child: RegistrationStatusPage(
                                  event: event,
                                  eventId: event.id,
                                  // Pass dummy data to the status page
                                  dummyRegistration: EventRegistration(
                                    id: "1",
                                    eventId: event.id,
                                    participantId: "1",
                                    status: "approved",
                                    badge: ParticipantBadge(
                                      id: "1234",
                                      participantId: "1",
                                      qrCode: 'DUMMY_QR_CODE',
                                      eventId:
                                          '12345', // Replace with participant ID
                                      //organization: 'Example Corp', // Replace with organization name
                                      generatedAt: DateTime.now(),
                                    ),
                                    registeredAt: DateTime.now(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
