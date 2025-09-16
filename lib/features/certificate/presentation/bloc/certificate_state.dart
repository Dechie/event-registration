import 'package:event_reg/features/certificate/data/models/certificate.dart';

abstract class CertificateState {
  const CertificateState();
}

class CertificateInitial extends CertificateState {
  const CertificateInitial();
}

class CertificateLoading extends CertificateState {
  const CertificateLoading();
}

class CertificateLoaded extends CertificateState {
  final Certificate certificate;
  
  const CertificateLoaded({required this.certificate});
}

class MyCertificatesLoaded extends CertificateState {
  final List<Certificate> certificates;
  
  const MyCertificatesLoaded({required this.certificates});
}

class CertificateError extends CertificateState {
  final String message;
  
  const CertificateError({required this.message});
}

