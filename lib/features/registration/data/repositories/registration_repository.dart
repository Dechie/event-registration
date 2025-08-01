import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/core/shared/models/participant.dart';
import 'package:event_reg/features/registration/data/datasources/registratoin_local_datasource.dart';
import 'package:event_reg/features/registration/data/models/registration_response.dart';
import 'package:event_reg/features/registration/data/models/registration_result.dart';

import '../datasources/registration_remote_datasource.dart';

abstract class RegistrationRepository {
  Future<List<Participant>> getAllParticipants(
    String? searchQuery,
    String? sessionFilter,
    String? statusFilter,
  );
  Future<Participant?> getParticipantByEmail(String email);
  Future<RegistrationResponse> registerParticipant(Participant participant);
  Future<void> sendOTP(String email);
  Future<bool> verifyOTP(String email, String otp);
}

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationRemoteDataSource remoteDataSource;
  final RegistrationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RegistrationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Participant>> getAllParticipants(
    String? searchQuery,
    String? sessionFilter,
    String? statusFilter,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final participants = await remoteDataSource.getAllParticipants(
          
        );

        // Cache all participants
        for (final participant in participants) {
          await localDataSource.cacheParticipant(participant);
        }

        return participants;
      } catch (e) {
        // Fallback to cached data
        return await localDataSource.getAllCachedParticipants();
      }
    } else {
      return await localDataSource.getAllCachedParticipants();
    }
  }

  @override
  Future<Participant?> getParticipantByEmail(String email) async {
    try {
      // Try local cache first
      final cachedParticipant = await localDataSource.getParticipantByEmail(
        email,
      );
      if (cachedParticipant != null) {
        return cachedParticipant;
      }

      // If not in cache and connected, try remote
      if (await networkInfo.isConnected) {
        final participant = await remoteDataSource.getParticipantByEmail(email);
        if (participant != null) {
          await localDataSource.cacheParticipant(participant);
        }
        return participant;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get participant: ${e.toString()}');
    }
  }

  @override
  Future<RegistrationResponse> registerParticipant(
    Participant participant,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.registerParticipant(participant);

        // Cache the participant locally
        await localDataSource.cacheParticipant(result.participant);

        return result;
      } catch (e) {
        throw Exception('Failed to register participant: ${e.toString()}');
      }
    } else {
      // Store locally and sync later
      await localDataSource.cacheParticipant(participant);
      throw Exception('No internet connection. Registration saved locally.');
    }
  }

  @override
  Future<void> sendOTP(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendOtp(email);
        // Cache the email for offline verification if needed
        await localDataSource.cacheEmail(email);
      } catch (e) {
        throw Exception('Failed to send OTP: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<bool> verifyOTP(String email, String otp) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.verifyOtp(email, otp);
      } catch (e) {
        throw Exception('Failed to verify OTP: ${e.toString()}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }
}
