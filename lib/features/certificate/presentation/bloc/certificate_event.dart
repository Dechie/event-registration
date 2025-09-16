abstract class CertificateEvent {
  const CertificateEvent();
}

class FetchCertificateRequested extends CertificateEvent {
  final String badgeNumber;
  
  const FetchCertificateRequested({required this.badgeNumber});
}

class FetchMyCertificatesRequested extends CertificateEvent {
  const FetchMyCertificatesRequested();
}

class RefreshCertificatesRequested extends CertificateEvent {
  const RefreshCertificatesRequested();
}

