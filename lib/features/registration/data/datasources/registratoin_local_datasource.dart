import 'dart:convert';

import 'package:event_reg/features/registration/data/models/participant.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RegistrationLocalDataSource {
  Future<void> cacheParticipant(Participant participant);
  Future<Participant?> getParticipantByEmail(String email);
  Future<List<Participant>> getAllCachedParticipants();
  Future<void> cacheEmail(String email);
  Future<void> clearCache();
}

class RegistrationLocalDataSourceImpl implements RegistrationLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _participantsKey = 'cached_participants';
  static const String _emailKey = 'cached_email';

  RegistrationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheParticipant(Participant participant) async {
    try {
      final participants = await getAllCachedParticipants();
      
      // Remove existing participant with same email if exists
      participants.removeWhere((p) => p.email == participant.email);
      
      // Add new participant
      participants.add(participant);
      
      final participantsJson = participants.map((p) => p.toJson()).toList();
      await sharedPreferences.setString(_participantsKey, jsonEncode(participantsJson));
    } catch (e) {
      throw Exception('Failed to cache participant: ${e.toString()}');
    }
  }

  @override
  Future<Participant?> getParticipantByEmail(String email) async {
    try {
      final participants = await getAllCachedParticipants();
      
      for (final participant in participants) {
        if (participant.email == email) {
          return participant;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get cached participant: ${e.toString()}');
    }
  }

  @override
  Future<List<Participant>> getAllCachedParticipants() async {
    try {
      final participantsString = sharedPreferences.getString(_participantsKey);
      
      if (participantsString == null) {
        return [];
      }
      
      final List<dynamic> participantsJson = jsonDecode(participantsString);
      return participantsJson.map((json) => Participant.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheEmail(String email) async {
    await sharedPreferences.setString(_emailKey, email);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_participantsKey);
    await sharedPreferences.remove(_emailKey);
  }
}