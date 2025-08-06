import 'package:event_reg/features/verification/data/models/verification_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/verification_bloc.dart';
import '../bloc/verification_event.dart';
import '../bloc/verification_state.dart';

// Custom overlay shape for QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + borderRadius,
          rect.top,
        )
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final newCutOutSize = cutOutSize < width
        ? cutOutSize
        : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - cutOutSize) / 2 + borderOffset,
      rect.top + (height - cutOutSize) / 2 + borderOffset,
      cutOutSize - borderOffset * 2,
      cutOutSize - borderOffset * 2,
    );

    // Draw overlay with cut out
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          )
          ..close(),
      ),
      backgroundPaint,
    );

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      borderPaint,
    );

    // Draw corner indicators
    final cornerLength = borderLength > cutOutSize / 2
        ? cutOutSize / 2
        : borderLength;
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 2;

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.top + cornerLength)
        ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
        ..quadraticBezierTo(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + borderRadius,
          cutOutRect.top,
        )
        ..lineTo(cutOutRect.left + cornerLength, cutOutRect.top),
      cornerPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - cornerLength, cutOutRect.top)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
        ..quadraticBezierTo(
          cutOutRect.right,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + borderRadius,
        )
        ..lineTo(cutOutRect.right, cutOutRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.bottom - cornerLength)
        ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
        ..quadraticBezierTo(
          cutOutRect.left,
          cutOutRect.bottom,
          cutOutRect.left + borderRadius,
          cutOutRect.bottom,
        )
        ..lineTo(cutOutRect.left + cornerLength, cutOutRect.bottom),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - cornerLength, cutOutRect.bottom)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.bottom)
        ..quadraticBezierTo(
          cutOutRect.right,
          cutOutRect.bottom,
          cutOutRect.right,
          cutOutRect.bottom - borderRadius,
        )
        ..lineTo(cutOutRect.right, cutOutRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  String? lastScannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () => cameraController.toggleTorch(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                  default:
                    return const Icon(Icons.flash_off);
                }
              },
            ),
          ),
          IconButton(
            onPressed: () => cameraController.switchCamera(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                  default:
                    return const Icon(Icons.camera_front);
                }
              },
            ),
          ),
        ],
      ),
      body: BlocListener<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state is VerificationLoading) {
            _showLoadingDialog();
          } else if (state is VerificationSuccess) {
            _dismissDialog();
            _showSuccessDialog(
              state.response.message,
              state.response.participant,
            );
          } else if (state is VerificationFailure) {
            _dismissDialog();
            _showErrorDialog('Verification Failed', state.message);
          }
        },
        child: Stack(
          children: [
            MobileScanner(controller: cameraController, onDetect: _onDetect),
            // Overlay with scanning area
            Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Colors.green,
                  borderRadius: 16,
                  borderLength: 30,
                  borderWidth: 8,
                  cutOutSize: 250,
                ),
              ),
            ),
            // Instructions at the bottom
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Position the QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isScanning ? 'Scanning...' : 'Processing...',
                      style: TextStyle(
                        color: isScanning ? Colors.green : Colors.orange,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: valueColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantInfo(ParticipantInfo participant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participant Details',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Name:', participant.fullName),
        _buildInfoRow('Email:', participant.email),
        if (participant.phoneNumber?.isNotEmpty == true)
          _buildInfoRow('Phone:', participant.phoneNumber!),
        if (participant.organization?.isNotEmpty == true)
          _buildInfoRow('Organization:', participant.organization!),
        if (participant.badgeNumber?.isNotEmpty == true)
          _buildInfoRow('Badge Number:', participant.badgeNumber!),
        _buildInfoRow(
          'Status:',
          participant.isVerified ? 'Verified' : 'Not Verified',
          valueColor: participant.isVerified ? Colors.green : Colors.orange,
        ),
        if (participant.verifiedAt != null)
          _buildInfoRow(
            'Verified At:',
            _formatDateTime(participant.verifiedAt!),
          ),
      ],
    );
  }

  void _dismissDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  String _extractBadgeNumber(String qrCode) {
    // Assuming QR code contains just the badge number
    // Modify this logic based on your QR code format
    return qrCode.trim();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code != lastScannedCode) {
        lastScannedCode = code;
        setState(() {
          isScanning = false;
        });

        // Extract badge number from QR code
        final badgeNumber = _extractBadgeNumber(code);
        if (badgeNumber.isNotEmpty) {
          context.read<VerificationBloc>().add(
            VerifyBadgeRequested(badgeNumber),
          );
        } else {
          _showErrorDialog(
            'Invalid QR Code',
            'Could not extract badge number from QR code.',
          );
          _resetScanner();
        }
      }
    }
  }

  void _resetScanner() {
    setState(() {
      isScanning = true;
      lastScannedCode = null;
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verifying participant...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message, ParticipantInfo? participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Verification Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (participant != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildParticipantInfo(participant),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
