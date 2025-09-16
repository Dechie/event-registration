// // lib/features/certificate/presentation/pages/my_certificates_page.dart
// import 'package:event_reg/config/themes/app_colors.dart';
// import 'package:event_reg/features/certificate/data/models/certificate.dart';
// import 'package:event_reg/features/certificate/presentation/bloc/certificate_bloc.dart';
// import 'package:event_reg/features/certificate/presentation/bloc/certificate_event.dart';
// import 'package:event_reg/features/certificate/presentation/bloc/certificate_state.dart';
// import 'package:event_reg/features/certificate/presentation/pages/certificate_viewer_page.dart';
// import 'package:event_reg/features/landing/presentation/widgets/participant_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class MyCertificatesPage extends StatefulWidget {
//   const MyCertificatesPage({super.key});

//   @override
//   State<MyCertificatesPage> createState() => _MyCertificatesPageState();
// }

// class _MyCertificatesPageState extends State<MyCertificatesPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Certificates',
//           style: TextStyle(color: AppColors.primary),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.primary,
//         actions: [
//           BlocBuilder<CertificateBloc, CertificateState>(
//             builder: (context, state) {
//               return IconButton(
//                 icon: const Icon(Icons.refresh),
//                 onPressed: state is CertificateLoading
//                     ? null
//                     : () {
//                         context.read<CertificateBloc>().add(
//                           const RefreshCertificatesRequested(),
//                         );
//                       },
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: const ParticipantLandingDrawer(selectedTile: 3),
//       body: BlocBuilder<CertificateBloc, CertificateState>(
//         builder: (context, state) {
//           if (state is CertificateLoading) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading your certificates...'),
//                 ],
//               ),
//             );
//           }

//           if (state is CertificateError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 64, color: AppColors.error),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Failed to Load Certificates',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.error,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       state.message,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: AppColors.textSecondary),
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         context.read<CertificateBloc>().add(
//                           const FetchMyCertificatesRequested(),
//                         );
//                       },
//                       icon: const Icon(Icons.refresh),
//                       label: const Text('Retry'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           if (state is MyCertificatesLoaded) {
//             if (state.certificates.isEmpty) {
//               return _buildEmptyState();
//             }
//             return _buildCertificatesList(state.certificates);
//           }

//           return const Center(child: Text('Welcome to your certificates'));
//         },
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     context.read<CertificateBloc>().add(
//       const FetchMyCertificatesRequested(),
//     );
//   }

//   Widget _buildCertificateCard(Certificate certificate) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: () => _viewCertificate(certificate),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Certificate icon
//               Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.workspace_premium,
//                   color: AppColors.primary,
//                   size: 28,
//                 ),
//               ),
//               const SizedBox(width: 16),
              
//               // Certificate details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Certificate icon
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withValues(alpha: 0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.workspace_premium,
//                     size: 32,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   certificate.eventTitle,
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   certificate.organizationName,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white.withValues(alpha: 0.9),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Badge: ${certificate.badgeNumber}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white.withValues(alpha: 0.8),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),

//           // Certificate viewer
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: certificate.certificateUrl.isNotEmpty
//                     ? InteractiveViewer(
//                         child: Image.network(
//                           certificate.certificateUrl,
//                           fit: BoxFit.contain,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress.cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   const Text('Loading certificate...'),
//                                 ],
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.error_outline,
//                                     size: 64,
//                                     color: Colors.grey.shade400,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     'Failed to load certificate',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   TextButton.icon(
//                                     onPressed: () => _openInBrowser(context),
//                                     icon: const Icon(Icons.open_in_browser),
//                                     label: const Text('Open in Browser'),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       )
//                     : Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.description_outlined,
//                               size: 64,
//                               color: Colors.grey.shade400,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'Certificate not available',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//               ),
//             ),
//           ),

//           // Action buttons
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Certificate details card
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildDetailRow(
//                         'Participant',
//                         certificate.participantName,
//                         Icons.person,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         'Event',
//                         certificate.eventTitle,
//                         Icons.event,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         'Organization',
//                         certificate.organizationName,
//                         Icons.business,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         'Issue Date',
//                         _formatDate(certificate.issueDate),
//                         Icons.calendar_today,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         'Badge Number',
//                         certificate.badgeNumber,
//                         Icons.confirmation_number,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Action buttons row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () => _openInBrowser(context),
//                         icon: const Icon(Icons.open_in_browser),
//                         label: const Text('Open in Browser'),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _downloadCertificate(context),
//                         icon: const Icon(Icons.download),
//                         label: const Text('Download'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value, IconData icon) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: AppColors.primary,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(DateTime date) {
//     final months = [
//       'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   void _shareCertificate(BuildContext context) {
//     // TODO: Implement sharing functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Share functionality - Coming Soon!'),
//       ),
//     );
//   }

//   void _downloadCertificate(BuildContext context) {
//     if (certificate.certificateUrl.isNotEmpty) {
//       _openInBrowser(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Certificate not available for download'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }

//   void _copyCertificateUrl(BuildContext context) {
//     if (certificate.certificateUrl.isNotEmpty) {
//       Clipboard.setData(ClipboardData(text: certificate.certificateUrl));
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Certificate URL copied to clipboard'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Certificate URL not available'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }

//   void _openInBrowser(BuildContext context) async {
//     if (certificate.certificateUrl.isNotEmpty) {
//       final uri = Uri.parse(certificate.certificateUrl);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not open certificate in browser'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Certificate URL not available'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
// }Alignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       certificate.eventTitle,
//                       style = const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines = 2,
//                       overflow = TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height = 4),
//                     Text(
//                       certificate.organizationName,
//                       style = TextStyle(
//                         fontSize: 14,
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height = 4),
//                     Row(
//                       children = [
//                         Icon(
//                           Icons.confirmation_number,
//                           size: 14,
//                           color: AppColors.textSecondary,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           certificate.badgeNumber,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height = 2),
//                     Row(
//                       children = [
//                         Icon(
//                           Icons.calendar_today,
//                           size: 14,
//                           color: AppColors.textSecondary,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _formatDate(certificate.issueDate),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Status badge and arrow
//               Column(
//                 children = [
//                   _buildStatusBadge(certificate.status),
//                   const SizedBox(height: 8),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     size: 16,
//                     color: AppColors.textSecondary,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCertificatesList(List<Certificate> certificates) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         context.read<CertificateBloc>().add(
//           const RefreshCertificatesRequested(),
//         );
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16.0),
//         itemCount: certificates.length,
//         itemBuilder: (context, index) {
//           final certificate = certificates[index];
//           return _buildCertificateCard(certificate);
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.workspace_premium_outlined,
//               size: 80,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No Certificates Yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Complete events to earn certificates that will appear here.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade500,
//                 height: 1.4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status) {
//     Color badgeColor;
//     String statusText;
//     IconData statusIcon;

//     switch (status.toLowerCase()) {
//       case 'available':
//         badgeColor = Colors.green;
//         statusText = 'Available';
//         statusIcon = Icons.check_circle;
//         break;
//       case 'pending':
//         badgeColor = Colors.orange;
//         statusText = 'Pending';
//         statusIcon = Icons.hourglass_empty;
//         break;
//       case 'expired':
//         badgeColor = Colors.red;
//         statusText = 'Expired';
//         statusIcon = Icons.cancel;
//         break;
//       default:
//         badgeColor = Colors.grey;
//         statusText = 'Unknown';
//         statusIcon = Icons.help;
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: badgeColor.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(statusIcon, color: badgeColor, size: 14),
//           const SizedBox(width: 4),
//           Text(
//             statusText,
//             style: TextStyle(
//               color: badgeColor,
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   void _viewCertificate(Certificate certificate) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CertificateViewerPage(certificate: certificate),
//       ),
//     );
//   }
// }


// // lib/features/certificate/presentation/pages/certificate_viewer_page.dart
// import 'package:event_reg/config/themes/app_colors.dart';
// import 'package:event_reg/features/certificate/data/models/certificate.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';

// class CertificateViewerPage extends StatelessWidget {
//   final Certificate certificate;

//   const CertificateViewerPage({
//     super.key,
//     required this.certificate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Certificate'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () => _shareCertificate(context),
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               switch (value) {
//                 case 'download':
//                   _downloadCertificate(context);
//                   break;
//                 case 'copy_url':
//                   _copyCertificateUrl(context);
//                   break;
//                 case 'view_in_browser':
//                   _openInBrowser(context);
//                   break;
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'download',
//                 child: Row(
//                   children: [
//                     Icon(Icons.download),
//                     SizedBox(width: 12),
//                     Text('Download'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'copy_url',
//                 child: Row(
//                   children: [
//                     Icon(Icons.copy),
//                     SizedBox(width: 12),
//                     Text('Copy URL'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'view_in_browser',
//                 child: Row(
//                   children: [
//                     Icon(Icons.open_in_browser),
//                     SizedBox(width: 12),
//                     Text('Open in Browser'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Certificate header info
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxis