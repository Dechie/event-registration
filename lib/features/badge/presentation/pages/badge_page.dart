import 'dart:io';
import 'dart:ui' as ui;

import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/core/shared/widgets/custom_button.dart';
import 'package:event_reg/features/event_registration/data/models/event_badge_data.dart';
import 'package:event_reg/features/landing/data/models/event.dart';
import 'package:event_reg/injection_container.dart' as di;
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
  final GlobalKey _frontBadgeKey = GlobalKey();
  final GlobalKey _backBadgeKey = GlobalKey();
  final UserDataService _userDataService = di.sl<UserDataService>();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  bool _showBack = false;

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
            // Badge View Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Front'),
                  selected: !_showBack,
                  onSelected: (selected) => setState(() => _showBack = false),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Back'),
                  selected: _showBack,
                  onSelected: (selected) => setState(() => _showBack = true),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Badge Preview
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showBack
                    ? RepaintBoundary(
                        key: _backBadgeKey,
                        child: _buildBackBadge(),
                      )
                    : RepaintBoundary(
                        key: _frontBadgeKey,
                        child: _buildFrontBadge(),
                      ),
              ),
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
                        return;
                      } else {
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
                        return;
                      } else {
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

  Widget _buildBackBadge() {
    final badgeData = EventBadgeData.fromEventDetails(widget.registrationData!);

    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
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
      child: Stack(
        children: [
          // Main white container
          Container(
            width: 300,
            height: 450,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Orange/amber side decorative strips
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Top hole punch area
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

              // Organization logo/name area
              SizedBox(
                height: 60,
                width: 60,
                child: Image.asset("assets/logo.png"),
              ),

              const SizedBox(height: 24),

              // Event title in box
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo.shade800, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeData.eventTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Date range
              Text(
                _formatDateRange(widget.event.startTime, widget.event.endTime),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),
              SizedBox(
                height: 40,
                child: Column(
                  children: [
                    Text(
                      "For Technical Support",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDisabledDark,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.email,
                          color: AppColors.textDisabledDark,
                          size: 8,
                        ),
                        Text(
                          "icteventhub@gmail.com",
                          style: TextStyle(
                            color: AppColors.textDisabledDark,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.email,
                          color: AppColors.textDisabledDark,
                          size: 8,
                        ),
                        Text(
                          "+ 251 9 10 21 08 14",
                          style: TextStyle(
                            color: AppColors.textDisabledDark,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildFrontBadge() {
    final badgeData = EventBadgeData.fromEventDetails(widget.registrationData!);

    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
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
      child: Stack(
        children: [
          // Main white container
          Container(
            width: 300,
            height: 450,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Orange/amber side decorative strips
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Top hole punch area
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              // Participant Photo (Square)
              Container(
                width: 130,
                height: 130,
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
                          errorBuilder: (_, __, ___) =>
                              _buildPhotoPlaceholder(),
                        ),
                      )
                    : _buildPhotoPlaceholder(),
              ),

              const SizedBox(height: 8),

              // Participant Name (Orange, Large)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  badgeData.participantName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Occupation/Role
              Text(
                'TRAINEE',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.eccBlue,
                  fontWeight: FontWeight.w600,
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
                    // QR Code (Larger)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: QrImageView(
                        data: badgeData
                            .badgeNumber, // Always use badge number for QR code
                        version: QrVersions.auto,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),

                    // Participant Info Box
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.eccBlue, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PARTICIPANT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.eccBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badgeData.badgeNumber,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade600,
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
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return const Icon(Icons.person, size: 60, color: Colors.grey);
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    if (end == null) return _formatDate(start);

    final startFormatted = _formatDate(start);
    final endFormatted = _formatDate(end);

    return '$startFormatted – $endFormatted\n${start.year}';
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
      // Wait for the widget tree to build
      await Future.delayed(Duration.zero);

      final frontContext = _frontBadgeKey.currentContext;
      final backContext = _backBadgeKey.currentContext;
      if (frontContext == null || backContext == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Badge is not visible. Please make sure the badge is displayed before downloading.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isGeneratingPdf = false;
        });
        return;
      }

      final frontBoundary =
          frontContext.findRenderObject() as RenderRepaintBoundary?;
      final backBoundary =
          backContext.findRenderObject() as RenderRepaintBoundary?;
      if (frontBoundary == null || backBoundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not capture badge image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isGeneratingPdf = false;
        });
        return;
      }

      final frontImage = await frontBoundary.toImage(pixelRatio: 3.0);
      final backImage = await backBoundary.toImage(pixelRatio: 3.0);

      final frontByteData = await frontImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final backByteData = await backImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (frontByteData == null || backByteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to capture badge image data.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isGeneratingPdf = false;
        });
        return;
      }

      final frontPngBytes = frontByteData.buffer.asUint8List();
      final backPngBytes = backByteData.buffer.asUint8List();

      // Create PDF
      final pdf = pw.Document();
      final frontBadgeImage = pw.MemoryImage(frontPngBytes);
      final backBadgeImage = pw.MemoryImage(backPngBytes);

      // Add front badge page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Event Registration Badge - Front',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Image(frontBadgeImage, width: 300, height: 400),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Please present this badge at the event venue',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Add back badge page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Event Registration Badge - Back',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Image(backBadgeImage, width: 300, height: 400),
                ),
                pw.SizedBox(height: 20),
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
              label: 'Open',
              onPressed: () {
                // You can implement opening the PDF here
              },
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
      // Capture both badges as images
      final frontBoundary =
          _frontBadgeKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final backBoundary =
          _backBadgeKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final frontImage = await frontBoundary.toImage(pixelRatio: 3.0);
      final backImage = await backBoundary.toImage(pixelRatio: 3.0);

      final frontByteData = await frontImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final backByteData = await backImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      final frontPngBytes = frontByteData!.buffer.asUint8List();
      final backPngBytes = backByteData!.buffer.asUint8List();

      // Save temporary images
      final directory = await getTemporaryDirectory();
      final frontFile = File(
        '${directory.path}/event_badge_front_${widget.event.id}.png',
      );
      final backFile = File(
        '${directory.path}/event_badge_back_${widget.event.id}.png',
      );

      await frontFile.writeAsBytes(frontPngBytes);
      await backFile.writeAsBytes(backPngBytes);

      // Share images
      // await Share.shareXFiles([
      //   XFile(frontFile.path),
      //   XFile(backFile.path),
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
