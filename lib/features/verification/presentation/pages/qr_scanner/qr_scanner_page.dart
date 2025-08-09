import 'dart:async';
import 'dart:convert';

import 'package:event_reg/features/verification/data/models/coupon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../data/models/participant_info.dart';
import '../../bloc/verification_bloc.dart';
import '../../bloc/verification_event.dart';
import '../../bloc/verification_state.dart';
import '../coupon_selection_page.dart';

part 'qr_overlay_shape.dart';

class QrScannerPage extends StatefulWidget {
  final String verificationType;
  final String? eventSessionId;
  final String? sessionTitle;
  
  const QrScannerPage({
    super.key, 
    this.verificationType = 'security',
    this.eventSessionId,
    this.sessionTitle,
  });
  
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
  ParticipantInfo? _currentParticipant;

  StreamSubscription<BarcodeCapture>? _subscription;
  bool isScanning = true;
  String? lastScannedCode;

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "qrscanner page: verification type is: ${widget.verificationType}",
    );
    if (widget.eventSessionId != null) {
      debugPrint("qrscanner page: eventSessionId is: ${widget.eventSessionId}");
      debugPrint("qrscanner page: sessionTitle is: ${widget.sessionTitle}");
    }

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

            // Special handling for coupon verification
            if (widget.verificationType == 'coupon' &&
                state.response.participant != null) {
              // Fetch coupons for the participant
              context.read<VerificationBloc>().add(
                FetchParticipantCoupons(
                  state.response.participant!.id,
                  state.response.participant!, // Pass the participant info
                ),
              );
            } else {
              _navigateToResultPage(state.response, state.badgeNumber);
            }
          } else if (state is CouponsFetched) {
            _dismissDialog();
            _navigateToCouponSelection(
              state.coupons,
              state.participant,
            ); // Updated signature
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
                    if (widget.sessionTitle != null) ...[
                      Text(
                        'Session: ${widget.sessionTitle}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
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
        return widget.sessionTitle != null 
            ? 'Attendance - ${widget.sessionTitle}'
            : 'Scan for Attendance';
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
          
          // Use the session ID from widget if available, otherwise from QR data
          final eventSessionId = widget.eventSessionId ?? badgeData['eventsession_id']?.toString();
          
          context.read<VerificationBloc>().add(
            VerifyBadgeRequested(
              badgeNumber,
              verificationType: widget.verificationType,
              eventSessionId: eventSessionId,
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

  void _navigateToCouponSelection(
    List<Coupon> coupons,
    ParticipantInfo participant,
  ) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<VerificationBloc>(),
          child: CouponSelectionPage(
            coupons: coupons,
            participant: participant,
            badgeNumber: lastScannedCode ?? '',
          ),
        ),
      ),
    );
  }

  void _navigateToResultPage(dynamic response, String badgeNumber) {
    Navigator.pushReplacementNamed(
      context,
      '/verification-result',
      arguments: {
        'type': widget.verificationType,
        'response': response,
        'badgeNumber': badgeNumber,
        'sessionTitle': widget.sessionTitle,
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
