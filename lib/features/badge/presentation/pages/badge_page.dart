import 'dart:io';
import 'dart:ui' as ui;

import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/event_registration/data/models/event_badge_data.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:event_reg/injection_container.dart' as di;
import 'package:event_reg/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
//import 'package:share_plus/share_plus.dart';

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
    final badgeData = EventBadgeData.fromEventDetails(widget.registrationData!);

    return Container(
      width: 300,
      height: 420, // Adjust for badge proportions
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          // Top hole punch area (black thin rectangle)
          Container(
            width: 80,
            height: 8,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 20),

          // Event Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              badgeData.eventTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Participant Photo (Square)
          // Replace the photo container section with:
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: badgeData.downloadedImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(badgeData.downloadedImagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
                    ),
                  )
                : _buildPhotoPlaceholder(),
          ),

          const SizedBox(height: 20),

          // Participant Name (Orange, Large)
          Text(
            badgeData.participantName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),

          const Spacer(),

          // Bottom Row: QR Code and Participant Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // QR Code
                SizedBox(
                  width: 80,
                  height: 80,
                  child: QrImageView(
                    data: badgeData.badgeNumber,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),
                ),

                // Participant Info Box
                Container(
                  width: 120,
                  height: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'PARTICIPANT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badgeData.participantId,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildPhotoPlaceholder() {
    return const Icon(Icons.person, size: 50, color: Colors.grey);
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
              onPressed: () {}, // => Share.shareXFiles([XFile(file.path)]),
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
      final userDataService = di.sl<UserDataService>();
      final user = await userDataService.getCachedUser();

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
      // await Share.shareXFiles([
      //   XFile(file.path),
      // ], text: 'My badge for ${widget.event.title}');
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
