import 'package:event_reg/config/themes/app_colors.dart';
import 'package:flutter/material.dart';

class EventHighlightsCard extends StatelessWidget {
  const EventHighlightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Highlights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildHighlightItem(
            icon: Icons.star,
            text: 'Expert speakers from leading companies',
          ),
          const SizedBox(height: 12),

          _buildHighlightItem(
            icon: Icons.network_check,
            text: 'Networking opportunities with industry professionals',
          ),
          const SizedBox(height: 12),

          _buildHighlightItem(
            icon: Icons.school,
            text: 'Hands-on workshops and skill development sessions',
          ),
          const SizedBox(height: 12),

          _buildHighlightItem(
            icon: Icons.card_giftcard,
            text: 'Certificate of participation and networking materials',
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
