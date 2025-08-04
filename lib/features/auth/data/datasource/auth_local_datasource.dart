// lib/features/auth/data/datasources/auth_local_datasource.dart

import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/auth/data/models/login/login_response.dart';
import 'package:event_reg/features/auth/data/models/user.dart'; // Corrected import path
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheUserData(LoginResponse loginResponse);
  Future<void> clearUserData();
  Future<LoginResponse?> getCachedUserData();
  Future<bool> isAuthenticated();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final UserDataService userDataService;
  final SharedPreferences sharedPrefs;

  AuthLocalDatasourceImpl({
    required this.userDataService,
    required this.sharedPrefs,
  });

  @override
  Future<void> cacheUserData(LoginResponse loginResponse) async {
    try {
      // Use the new granular setter methods from UserDataService
      await userDataService.setAuthToken(loginResponse.token);
      await userDataService.setUserId(loginResponse.user.id);
      await userDataService.setUserEmail(loginResponse.user.email);
      await userDataService.setUserType(loginResponse.user.userType);
      
      // Use the User model's getters to get the status flags
      await userDataService.setEmailVerified(loginResponse.user.isEmailVerified);
      // We assume 'hasProfile' and 'isProfileCompleted' are equivalent to
      // the 'hasCompletedProfile' getter for now.
      await userDataService.setHasProfile(loginResponse.user.hasCompletedProfile);
      await userDataService.setProfileCompleted(loginResponse.user.hasCompletedProfile);

      // Cache other profile fields if present
      await userDataService.setFullName(loginResponse.user.fullName ?? '');
      await userDataService.setPhoneNumber(loginResponse.user.phoneNumber ?? '');
      await userDataService.setOccupation(loginResponse.user.occupation ?? '');
      await userDataService.setOrganization(loginResponse.user.organization ?? '');
      await userDataService.setGender(loginResponse.user.gender ?? '');
      await userDataService.setNationality(loginResponse.user.nationality ?? '');
      await userDataService.setRegion(loginResponse.user.region ?? '');
      await userDataService.setCity(loginResponse.user.city ?? '');
      await userDataService.setWoreda(loginResponse.user.woreda ?? '');
      await userDataService.setIdNumber(loginResponse.user.idNumber ?? '');
      await userDataService.setDepartment(loginResponse.user.department ?? '');
      await userDataService.setIndustry(loginResponse.user.industry ?? '');
      await userDataService.setYearsOfExperience(loginResponse.user.yearsOfExperience ?? 0);
      await userDataService.setPhotoPath(loginResponse.user.photoPath ?? '');

    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: "Failed to cache user data",
        code: "CACHE_WRITE_ERROR",
      );
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await userDataService.clearAllData();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: "Failed to clear user data",
        code: "CACHE_CLEAR_ERROR",
      );
    }
  }

  @override
  Future<LoginResponse?> getCachedUserData() async {
    try {
      final token = await userDataService.getAuthToken();
      final userId = await userDataService.getUserId();
      final userEmail = await userDataService.getUserEmail();
      final userType = await userDataService.getUserType();
      final fullName = await userDataService.getFullName();
      final phoneNumber = await userDataService.getPhoneNumber();
      final occupation = await userDataService.getOccupation();
      final organization = await userDataService.getOrganization();
      final gender = await userDataService.getGender();
      final nationality = await userDataService.getNationality();
      final region = await userDataService.getRegion();
      final city = await userDataService.getCity();
      final woreda = await userDataService.getWoreda();
      final idNumber = await userDataService.getIdNumber();
      final department = await userDataService.getDepartment();
      final industry = await userDataService.getIndustry();
      final yearsOfExperience = await userDataService.getYearsOfExperience();
      final photoPath = await userDataService.getPhotoPath();

      if (token != null && userId != null && userEmail != null && userType != null) {
        // Reconstruct the User and LoginResponse object from the cached data
        final user = User(
          id: userId,
          email: userEmail,
          userType: userType,
          fullName: fullName,
          phoneNumber: phoneNumber,
          occupation: occupation,
          organization: organization,
          gender: gender,
          nationality: nationality,
          region: region,
          city: city,
          woreda: woreda,
          idNumber: idNumber,
          department: department,
          industry: industry,
          yearsOfExperience: yearsOfExperience,
          photoPath: photoPath,
          // Other fields would be null from the local cache as they are not explicitly stored
        );

        return LoginResponse(
          id: user.id,
          message: "User Data Cached Successfully.",
          user: user,
          token: token,
        );
      }
      return null;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: "Failed to retreive cached user data",
        code: 'CACHE_READ_ERROR',
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final authStatus = await userDataService.getAuthenticationStatus();
      return authStatus.isAuthenticated;
    } catch (e) {
      return false;
    }
  }
}