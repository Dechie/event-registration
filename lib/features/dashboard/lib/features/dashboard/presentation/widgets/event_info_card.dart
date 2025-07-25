import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/event_info.dart';

class EventInfoCard extends StatelessWidget {
  final EventInfo eventInfo;

  const EventInfoCard({
    super.key,
    required this.eventInfo,
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
                const Icon(Icons.event, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Event Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (eventInfo.bannerUrl != null)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(eventInfo.bannerUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              eventInfo.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventInfo.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Date',
              '${_formatDate(eventInfo.startDate)} - ${_formatDate(eventInfo.endDate)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.location_on,
              'Venue',
              eventInfo.venue,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.place,
              'Address',
              eventInfo.address,
              trailing: eventInfo.googleMapsLink != null
                  ? TextButton(
                      onPressed: () => _launchMaps(eventInfo.googleMapsLink!),
                      child: const Text('View Map'),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.phone,
              'Contact',
              eventInfo.contactInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    {Widget? trailing}
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _launchMaps(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
