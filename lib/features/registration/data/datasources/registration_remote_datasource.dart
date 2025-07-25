


import 'package:event_reg/core/network/dio_client.dart';
import 'package:event_reg/features/registration/data/models/participant.dart';
import 'package:event_reg/features/registration/data/models/registration_result.dart';

abstract class RegistrationRemoteDataSource {
  Future<void> sendOTP(String email);
  Future<bool> verifyOTP(String email, String otp);
  Future<RegistrationResult> registerParticipant(Participant participant);
  Future<Participant?> getParticipantByEmail(String email);
  Future<List<Participant>> getAllParticipants();
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  final DioClient dioClient;

  RegistrationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<void> sendOTP(String email) async {
    try {
      await dioClient.post('/auth/send-otp', data: {'email': email});
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final response = await dioClient.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<RegistrationResult> registerParticipant(Participant participant) async {
    try {
      final response = await dioClient.post('/participants', data: participant.toJson());
      
      final participantData = response.data['participant'];
      final qrCode = response.data['qrCode'];
      
      return RegistrationResult(
        participant: Participant.fromJson(participantData),
        qrCode: qrCode,
      );
    } catch (e) {
      throw Exception('Failed to register participant: ${e.toString()}');
    }
  }

  @override
  Future<Participant?> getParticipantByEmail(String email) async {
    try {
      final response = await dioClient.get('/participants/by-email', queryParams: {
        'email': email,
      });
      
      if (response.data != null) {
        return Participant.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get participant: ${e.toString()}');
    }
  }

  @override
  Future<List<Participant>> getAllParticipants() async {
    try {
      final response = await dioClient.get('/participants');
      
      final List<dynamic> participantsJson = response.data['participants'];
      return participantsJson.map((json) => Participant.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get participants: ${e.toString()}');
    }
  }
}

