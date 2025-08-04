import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BadgePreviewWidget extends StatelessWidget {
  final Event event;
  final Map<String, dynamic>? userData;
  final String badgeId;

  const BadgePreviewWidget({
    super.key,
    required this.event,
    this.userData,
    required this.badgeId,
  });

  @override
  Widget build(BuildContext context) {
    final participant = userData?['participant'];

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'EVENT PARTICIPANT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Photo
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.background,
            backgroundImage: participant?['photo'] != null
                ? NetworkImage(participant['photo'])
                : null,
            child: participant?['photo'] == null
                ? Icon(Icons.person, size: 40, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            participant?['name'] ?? userData?['name'] ?? 'Participant',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            userData?['email'] ?? '',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Event
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              event.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // Date
          Text(
            _formatDate(event.startTime),
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // QR Code
          QrImageView(
            data: badgeId,
            version: QrVersions.auto,
            size: 60,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 4),

          // Badge ID
          Text(
            'ID: ${badgeId.substring(0, 8)}...',
            style: TextStyle(
              fontSize: 8,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
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
}
