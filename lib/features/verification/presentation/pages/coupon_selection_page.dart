// lib/features/verification/presentation/pages/coupon_selection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/coupon.dart';
import '../../data/models/participant_info.dart';
import '../bloc/verification_bloc.dart';
import '../bloc/verification_event.dart';

class CouponSelectionPage extends StatefulWidget {
  final List<Coupon> coupons;
  final ParticipantInfo participant;
  final String badgeNumber;

  const CouponSelectionPage({
    super.key,
    required this.coupons,
    required this.participant,
    required this.badgeNumber,
  });

  @override
  State<CouponSelectionPage> createState() => _CouponSelectionPageState();
}

class _CouponSelectionPageState extends State<CouponSelectionPage> {
  Coupon? selectedCoupon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Coupon'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Participant Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Participant Information',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Name', widget.participant.fullName),
                    _buildInfoRow('Email', widget.participant.email),
                    _buildInfoRow('Badge Number', widget.badgeNumber),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Coupon Selection Section
            Text(
              'Available Coupons (${widget.coupons.length})',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (widget.coupons.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Coupons Available',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This participant has no available coupons.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...widget.coupons.map((coupon) => _buildCouponCard(coupon)),

            if (widget.coupons.isNotEmpty && selectedCoupon != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _validateCoupon(),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Validate Selected Coupon'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Another Code'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isSelected = selectedCoupon?.id == coupon.id;
    final isRedeemed = coupon.isRedeemed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: isRedeemed
            ? null
            : () {
                setState(() {
                  selectedCoupon = isSelected ? null : coupon;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.orange, width: 2)
                : null,
            color: isRedeemed
                ? Colors.grey[100]
                : isSelected
                ? Colors.orange.withValues(alpha: 0.1)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isRedeemed
                          ? Colors.grey[300]
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isRedeemed ? Icons.redeem : Icons.local_offer,
                      color: isRedeemed ? Colors.grey[600] : Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isRedeemed ? Colors.grey[600] : null,
                              ),
                        ),
                        if (coupon.value?.isNotEmpty == true)
                          Text(
                            'Value: ${coupon.value}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isRedeemed
                                      ? Colors.grey[500]
                                      : Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (isRedeemed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'REDEEMED',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SELECTED',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (coupon.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  coupon.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isRedeemed ? Colors.grey[500] : Colors.grey[700],
                  ),
                ),
              ],
              if (isRedeemed && coupon.redeemedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Redeemed on: ${_formatDateTime(coupon.redeemedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _validateCoupon() {
    if (selectedCoupon != null) {
      // Trigger coupon validation
      context.read<VerificationBloc>().add(
        VerifyBadgeRequested(
          badgeNumber: widget.badgeNumber,
          verificationType: 'coupon',
          couponId: selectedCoupon!.id,
        ),
      );
    }
  }
}
