// lib/features/dashboard/presentation/widgets/participant_info_card.dart
import 'package:event_reg/core/shared/models/participant.dart';
import 'package:flutter/material.dart';

class ParticipantInfoCard extends StatelessWidget {
  final Participant participant;
  final bool canEdit;
  final VoidCallback? onEdit;

  const ParticipantInfoCard({
    super.key,
    required this.participant,
    required this.canEdit,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'My Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (canEdit)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: participant.photoUrl != null
                      ? NetworkImage(participant.photoUrl!)
                      : null,
                  child: participant.photoUrl == null
                      ? Text(
                          participant.fullName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        participant.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        participant.phoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoSection(context, 'Personal Information', [
              _InfoItem('Gender', participant.gender ?? 'Not specified'),
              _InfoItem(
                'Date of Birth',
                participant.dateOfBirth?.toLocal().toString().split(' ')[0] ??
                    'Not specified',
              ),
              _InfoItem(
                'Nationality',
                participant.nationality ?? 'Not specified',
              ),
              _InfoItem('Region', participant.region ?? 'Not specified'),
              _InfoItem('City', participant.city ?? 'Not specified'),
              _InfoItem('Woreda', participant.woreda ?? 'Not specified'),
              _InfoItem('ID Number', participant.idNumber ?? 'Not specified'),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection(context, 'Professional Information', [
              _InfoItem('Occupation', participant.occupation),
              _InfoItem('Organization', participant.organization),
              _InfoItem(
                'Department',
                participant.department ?? 'Not specified',
              ),
              _InfoItem('Industry', participant.industry),
              _InfoItem(
                'Years of Experience',
                '${participant.yearsOfExperience ?? 0} years',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<_InfoItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    '${item.label}:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
