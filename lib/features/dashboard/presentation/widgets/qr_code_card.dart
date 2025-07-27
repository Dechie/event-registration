// lib/features/dashboard/presentation/widgets/qr_code_card.dart
import 'package:event_reg/core/shared/models/participant.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeCard extends StatelessWidget {
  final String qrCode;
  final Participant participant;
  final String confirmationStatus;

  const QRCodeCard({
    super.key,
    required this.qrCode,
    required this.participant,
    required this.confirmationStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'My Ticket',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: qrCode,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    participant.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    participant.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${participant.id}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Show this QR code at the event entrance for quick check-in',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    Color colorWithShade;
    String label;

    switch (confirmationStatus.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        colorWithShade = Colors.green.shade800;
        label = 'Confirmed';
        break;
      case 'pending':
        color = Colors.orange;
        colorWithShade = Colors.orange.shade800;
        label = 'Pending';
        break;
      case 'checked-in':
        color = Colors.blue;
        colorWithShade = Colors.blue.shade800;
        label = 'Checked In';
        break;
      default:
        color = Colors.grey;
        colorWithShade = Colors.grey.shade800;
        label = 'Unknown';
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withAlpha(25),
      labelStyle: TextStyle(color: colorWithShade),
    );
  }
}
