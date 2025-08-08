// lib/features/verification/presentation/pages/verification_result_page.dart

import 'package:flutter/material.dart';

import '../../data/models/verification_response.dart';

class VerificationResultPage extends StatelessWidget {
  final String verificationType;
  final VerificationResponse response;
  final String badgeNumber;

  const VerificationResultPage({
    super.key,
    required this.verificationType,
    required this.response,
    required this.badgeNumber,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
        backgroundColor: _getBackgroundColor(),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(context, textTheme),

            const SizedBox(height: 20),

            // Participant Details (if available)
            if (response.participant != null) ...[
              _buildParticipantCard(context, textTheme),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context), // Go back to scanner
            icon: const Icon(Icons.qr_code_scanner),
            label: Text('Scan Another ${_getItemType()}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getBackgroundColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Go back to dashboard (pop twice)
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.dashboard),
            label: const Text('Back to Dashboard'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(BuildContext context, TextTheme textTheme) {
    final participant = response.participant!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Participant Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              'Name',
              participant.fullName,
              textTheme: textTheme,
            ),
            _buildInfoRow(
              context,
              'Email',
              participant.email,
              textTheme: textTheme,
            ),
            if (participant.phoneNumber?.isNotEmpty == true)
              _buildInfoRow(
                context,
                'Phone',
                participant.phoneNumber!,
                textTheme: textTheme,
              ),
            if (participant.organization?.isNotEmpty == true)
              _buildInfoRow(
                context,
                'Organization',
                participant.organization!,
                textTheme: textTheme,
              ),
            _buildInfoRow(
              context,
              'Verification Status',
              response.status ?? "Not Verified",
              valueColor: response.status == "Verified"
                  ? Colors.green
                  : Colors.orange,
              textTheme: textTheme,
            ),
            if (participant.verifiedAt != null)
              _buildInfoRow(
                context,
                'Verified At',
                _formatDateTime(participant.verifiedAt!),
                textTheme: textTheme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, TextTheme textTheme) {
    return Card(
      elevation: 4,
      color: _getBackgroundColor().withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(_getStatusIcon(), size: 80, color: _getBackgroundColor()),
            const SizedBox(height: 16),
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getBackgroundColor(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              response.message,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getBackgroundColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Badge: $badgeNumber',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getBackgroundColor() {
    if (!response.success) return Colors.red;

    switch (verificationType.toLowerCase()) {
      case 'attendance':
        return Colors.green;
      case 'security':
        return Colors.blue;
      case 'coupon':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getItemType() {
    switch (verificationType.toLowerCase()) {
      case 'attendance':
        return 'Code';
      case 'security':
        return 'Badge';
      case 'coupon':
        return 'Coupon';
      default:
        return 'QR Code';
    }
  }

  IconData _getStatusIcon() {
    if (!response.success) return Icons.error;

    switch (verificationType.toLowerCase()) {
      case 'attendance':
        return Icons.check_circle;
      case 'security':
        return Icons.verified;
      case 'coupon':
        return Icons.redeem;
      default:
        return Icons.check_circle;
    }
  }

  String _getStatusText() {
    if (!response.success) return 'Failed';

    switch (verificationType.toLowerCase()) {
      case 'attendance':
        return 'Checked In';
      case 'security':
        return 'Valid';
      case 'coupon':
        return 'Used';
      default:
        return 'Success';
    }
  }

  String _getTitle() {
    switch (verificationType.toLowerCase()) {
      case 'attendance':
        return 'Attendance Result';
      case 'security':
        return 'Security Check Result';
      case 'coupon':
        return 'Coupon Validation Result';
      default:
        return 'Verification Result';
    }
  }
}
