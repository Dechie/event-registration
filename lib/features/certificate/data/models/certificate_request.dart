class CertificateRequest {
  final String badgeNumber;

  const CertificateRequest({required this.badgeNumber});

  Map<String, dynamic> toJson() {
    return {'badge_number': badgeNumber};
  }
}
