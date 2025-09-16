import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/certificate/data/models/certificate.dart';
import 'package:flutter/material.dart' show debugPrint;

abstract class CertificateDataSource {
  Future<Certificate> getCertificate(String badgeNumber);
  Future<List<Certificate>> getMyCertificates();
}

class CertificateDataSourceImpl implements CertificateDataSource {
  final DioClient dioClient;
  final UserDataService userDataService;

  CertificateDataSourceImpl({
    required this.dioClient,
    required this.userDataService,
  });

  @override
  Future<Certificate> getCertificate(String badgeNumber) async {
    try {
      debugPrint('📋 Fetching certificate for badge: $badgeNumber');

      // Get auth token
      final token = await userDataService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Make API call
      final response = await dioClient.get(
        '/certificate/$badgeNumber',
        token: token,
      );

      debugPrint('✅ Certificate fetched successfully');
      debugPrint('📊 Response data: ${response.data}');

      // Parse the response
      final certificate = Certificate.fromJson(response.data);

      return certificate;
    } catch (e) {
      debugPrint('❌ Error fetching certificate: $e');
      rethrow;
    }
  }

  @override
  Future<List<Certificate>> getMyCertificates() async {
    try {
      debugPrint('📋 Fetching my certificates...');

      // Get auth token
      final token = await userDataService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Make API call to get user's certificates
      final response = await dioClient.get('/my-certificates', token: token);

      debugPrint('✅ My certificates fetched successfully');
      debugPrint('📊 Response data: ${response.data}');

      // Parse the response - assuming it returns a list of certificates
      final List<dynamic> certificatesData =
          response.data['certificates'] ?? [];
      final certificates = certificatesData
          .map((json) => Certificate.fromJson(json))
          .toList();

      return certificates;
    } catch (e) {
      debugPrint('❌ Error fetching my certificates: $e');
      rethrow;
    }
  }
}
