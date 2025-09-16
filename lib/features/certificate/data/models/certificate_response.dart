import 'package:event_reg/features/certificate/data/models/certificate.dart';

class CertificateResponse {
  final bool success;
  final String message;
  final Certificate? certificate;
  final String? error;

  const CertificateResponse({
    required this.success,
    required this.message,
    this.certificate,
    this.error,
  });

  factory CertificateResponse.fromJson(Map<String, dynamic> json) {
    return CertificateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      certificate: json['certificate'] != null 
          ? Certificate.fromJson(json['certificate'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'certificate': certificate?.toJson(),
      'error': error,
    };
  }
}