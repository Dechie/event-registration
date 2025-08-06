import 'package:event_reg/config/routes/route_names.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome, Admin',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose an action below to get started',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions section
            Text(
              'Quick Actions',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // QR Scanner buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 16,
                childAspectRatio: 3.2,
                children: [
                  _buildActionCard(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                    context,
                    icon: Icons.fact_check,
                    title: 'Take Attendance',
                    description: 'Scan QR codes to mark attendance for events',
                    color: Colors.green,
                    onTap: () => _navigateToScanner(context, 'attendance'),
                  ),
                  _buildActionCard(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                    context,
                    icon: Icons.security,
                    title: 'Check Security',
                    description: 'Verify participant credentials and access',
                    color: Colors.blue,
                    onTap: () => _navigateToScanner(context, 'security'),
                  ),
                  _buildActionCard(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                    context,
                    icon: Icons.local_offer,
                    title: 'Validate Coupon',
                    description: 'Scan and validate participant coupons',
                    color: Colors.orange,
                    onTap: () => _navigateToScanner(context, 'coupon'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:
                      MainAxisSize.min, // Changed to `min` to prevent overflow
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // This is the fix for the overflow error
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScanner(BuildContext context, String type) {
    Navigator.pushNamed(
      context,
      RouteNames.qrScannerPage,
      arguments: {'type': type},
    );
  }
}
