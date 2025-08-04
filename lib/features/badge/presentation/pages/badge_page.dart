import 'dart:io';
import 'dart:ui' as ui;

import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class BadgePage extends StatefulWidget {
  final Event event;
  final Map<String, dynamic>? registrationData;

  const BadgePage({super.key, required this.event, this.registrationData});

  @override
  State<BadgePage> createState() => _BadgePageState();
}

class _BadgePageState extends State<BadgePage> {
  final GlobalKey _badgeKey = GlobalKey();
  final UserDataService _userDataService = di.sl<UserDataService>();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Badge'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingPdf ? null : _generatePdf,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isGeneratingPdf ? null : _shareBadge,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Badge Preview
            Center(
              child: RepaintBoundary(key: _badgeKey, child: _buildBadge()),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: _isGeneratingPdf
                        ? 'Generating PDF...'
                        : 'Download PDF',
                    onPressed: () {
                      if (_isGeneratingPdf) {
                        _generatePdf();
                      }
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Share Badge',
                    onPressed: () {
                      if (_isGeneratingPdf) {
                        _shareBadge();
                      }
                    },
                    backgroundColor: AppColors.secondary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Event Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Event', widget.event.title),
                    _buildDetailRow('Location', widget.event.location),
                    _buildDetailRow(
                      'Date',
                      _formatDate(widget.event.startTime),
                    ),
                    _buildDetailRow(
                      'Time',
                      _formatTime(widget.event.startTime),
                    ),
                    if (widget.event.organization != null)
                      _buildDetailRow(
                        'Organizer',
                        widget.event.organization!.name,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Widget _buildAvatarPlaceholder() {
    return Icon(Icons.person, size: 50, color: AppColors.textSecondary);
  }

  Widget _buildBadge() {
    final participant = _userData?['participant'];
    final badgeId = '${widget.event.id}-${participant?['id'] ?? 'unknown'}';

    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'EVENT BADGE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Profile Photo Placeholder
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: participant?['photo'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      participant['photo'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                    ),
                  )
                : _buildAvatarPlaceholder(),
          ),
          const SizedBox(height: 16),

          // Participant Name
          Text(
            participant?['name'] ?? _userData?['name'] ?? 'Participant',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            _userData?['email'] ?? '',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Organization/Company
          if (participant?['company'] != null) ...[
            Text(
              participant['company'],
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          // Event Name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.event.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // Date
          Text(
            _formatDate(widget.event.startTime),
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // QR Code
          QrImageView(
            data: badgeId,
            version: QrVersions.auto,
            size: 80,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 8),

          // Badge ID
          Text(
            'ID: ${badgeId.substring(0, 12)}...',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // Capture badge as image
      final boundary =
          _badgeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Create PDF
      final pdf = pw.Document();
      final badgeImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Event Registration Badge',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Image(badgeImage, width: 300, height: 400)),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Please present this badge at the event venue',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Generated on: ${DateTime.now().toString().substring(0, 16)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            );
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/event_badge_${widget.event.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Badge PDF saved to ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userDataService.getCurrentUser();
      setState(() {
        _userData = user?.toJson();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareBadge() async {
    try {
      // Capture badge as image
      final boundary =
          _badgeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save temporary image
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/event_badge_${widget.event.id}.png');
      await file.writeAsBytes(pngBytes);

      // Share image
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'My badge for ${widget.event.title}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share badge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
