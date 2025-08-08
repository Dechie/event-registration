import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/verification_bloc.dart';
import '../bloc/verification_event.dart';
import '../bloc/verification_state.dart';

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      borderPaint,
    );

    final cornerLength = borderLength > cutOutSize / 2
        ? cutOutSize / 2
        : borderLength;
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 2;

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
  final String verificationType;
  const QrScannerPage({super.key, this.verificationType = 'security'});
  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 500,
    autoZoom: true,
  );

  StreamSubscription<BarcodeCapture>? _subscription;
  bool isScanning = true;
  String? lastScannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: controller,
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
            onPressed: () => controller.switchCamera(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: controller,
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
            debugPrint("state is verification success.");
            _dismissDialog();
            _navigateToResultPage(state.response, state.badgeNumber);
          } else if (state is VerificationFailure) {
            _dismissDialog();
            _showErrorDialog('Verification Failed', state.message);
          }
        },
        child: Stack(
          children: [
            MobileScanner(controller: controller),
            Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: _getBorderColor(),
                  borderRadius: 16,
                  borderLength: 30,
                  borderWidth: 8,
                  cutOutSize: 250,
                ),
              ),
            ),
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
                    Text(
                      _getInstructionText(),
                      style: const TextStyle(
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        unawaited(_subscription?.cancel());
        _subscription = controller.barcodes.listen(_handleBarcode);
        unawaited(controller.start());
        _resetScanner();
        break;
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
        break;
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  void _dismissDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Map<String, dynamic> _extractQrData(String qrCode) {
    debugPrint(
      'Step 1: Starting to extract QR data from raw string: "$qrCode"',
    );
    try {
      final data = qrCode.trim();
      if (data.startsWith('{') && data.endsWith('}')) {
        debugPrint(
          'Step 2: Raw data appears to be JSON. Attempting to decode.',
        );
        final decodedData = jsonDecode(data);
        debugPrint('Step 3: Successfully decoded JSON. Result: $decodedData');
        return Map<String, dynamic>.from(decodedData);
      } else {
        debugPrint(
          'Step 2: Raw data is not JSON. Treating as a plain badge number.',
        );
        return {'badge_number': data};
      }
    } catch (e) {
      debugPrint(
        'Step 2: Failed to decode JSON. Error: $e. Falling back to plain badge number.',
      );
      return {'badge_number': qrCode.trim()};
    }
  }

  String _getAppBarTitle() {
    switch (widget.verificationType.toLowerCase()) {
      case 'attendance':
        return 'Scan for Attendance';
      case 'security':
        return 'Security Check';
      case 'coupon':
        return 'Scan Coupon';
      case 'info':
        return 'Participant Info';
      default:
        return 'Scan QR Code';
    }
  }

  Color _getBorderColor() {
    switch (widget.verificationType.toLowerCase()) {
      case 'attendance':
        return Colors.green;
      case 'security':
        return Colors.blue;
      case 'coupon':
        return Colors.orange;
      case 'info':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  String _getInstructionText() {
    switch (widget.verificationType.toLowerCase()) {
      case 'attendance':
        return 'Position the attendance QR code within the frame';
      case 'security':
        return 'Position the badge QR code within the frame';
      case 'coupon':
        return 'Position the coupon QR code within the frame';
      case 'info':
        return 'Position the badge QR code within the frame';
      default:
        return 'Position the QR code within the frame';
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code != lastScannedCode) {
        lastScannedCode = code;
        setState(() {
          isScanning = false;
        });

        debugPrint('Step 4: Barcode detected with raw value: "$code"');
        final badgeData = _extractQrData(code);
        debugPrint('Step 5: Extracted badge data: $badgeData');

        if (badgeData['badge_number'] != null &&
            badgeData['badge_number'].toString().isNotEmpty) {
          debugPrint(
            'Step 6: Found a valid badge number. Adding event to Bloc.',
          );
          final badgeNumber = badgeData['badge_number'].toString();
          context.read<VerificationBloc>().add(
            VerifyBadgeRequested(
              badgeNumber,
              verificationType: widget.verificationType,
              eventSessionId: badgeData['eventsession_id']?.toString(),
              couponId: badgeData['coupon_id']?.toString(),
            ),
          );
        } else {
          debugPrint(
            'Step 6: Extracted badge number is null or empty. Showing error.',
          );
          _showErrorDialog(
            'Invalid QR Code',
            'Could not extract badge number from QR code.',
          );
          _resetScanner();
        }
      }
    }
  }

  void _navigateToResultPage(dynamic response, String badgeNumber) {
    Navigator.pushReplacementNamed(
      context,
      '/verification-result',
      arguments: {
        'type': widget.verificationType,
        'response': response,
        'badgeNumber': badgeNumber,
      },
    );
  }

  void _resetScanner() {
    if (mounted) {
      setState(() {
        isScanning = true;
        lastScannedCode = null;
      });
    }
    debugPrint('Scanner reset. Ready for the next scan.');
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
            onPressed: () => Navigator.pop(context),
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }
}
