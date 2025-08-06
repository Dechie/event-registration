import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

// Authentication Status Model
class AuthenticationStatus {
  final bool isAuthenticated;
  final String? token;
  final String? role;
  final String? email;
  final String? userId;
  final bool isEmailVerified;
  final bool hasProfile;
  final bool isProfileCompleted;

  const AuthenticationStatus({
    required this.isAuthenticated,
    this.token,
    this.role,
    this.email,
    this.userId,
    this.isEmailVerified = false,
    this.hasProfile = false,
    this.isProfileCompleted = false,
  });

  @override
  String toString() {
    return 'AuthStatus(isAuth: $isAuthenticated, role: $role, emailVerified: $isEmailVerified, hasProfile: $hasProfile, profileCompleted: $isProfileCompleted)';
  }
}

abstract class UserDataService {
  Future<void> clearAllData();
  // Enhanced authentication status
  Future<AuthenticationStatus> getAuthenticationStatus();
  // Existing methods...
  Future<String?> getAuthToken();
  Future<User?> getCachedUser();
  Future<String?> getCity();
  Future<String?> getDepartment();
  // Profile status methods
  Future<bool> getEmailVerified();
  Future<String?> getFullName();

  Future<String?> getGender();
  Future<String?> getIdNumber();
  Future<String?> getIndustry();

  Future<String?> getNationality();
  Future<String?> getOccupation();
  Future<String?> getOrganization();
  Future<String?> getPhoneNumber();
  Future<String?> getPhotoPath();
  Future<bool> getProfileCompleted();

  Future<String?> getRegion();
  Future<String?> getRole();

  Future<String?> getUserEmail();
  Future<String?> getUserId();
  Future<String?> getUserRole();
  Future<String?> getWoreda();
  Future<int?> getYearsOfExperience();
  Future<bool> isAuthenticated();
  // Profile getters
  Future<void> setAuthToken(String token);
  Future<void> setCity(String city);
  Future<void> setDepartment(String department);
  Future<void> setEmailVerified(bool isVerified);
  // Profile setters
  Future<void> setFullName(String fullName);
  Future<void> setGender(String gender);
  Future<void> setHasProfile(bool hasProfile);
  Future<void> setIdNumber(String idNumber);

  Future<void> setIndustry(String industry);
  Future<void> setNationality(String nationality);
  Future<void> setOccupation(String occupation);
  Future<void> setOrganization(String organization);
  Future<void> setPhoneNumber(String phoneNumber);
  Future<void> setPhotoPath(String photoPath);
  Future<void> setProfileCompleted(bool isCompleted);
  Future<void> setRegion(String region);
  Future<void> setRole(String role);
  Future<void> setUserEmail(String email);
  Future<void> setUserId(String userId);
  Future<void> setUserRole(String role);
  Future<void> setWoreda(String woreda);
  Future<void> setYearsOfExperience(int years);
}

class UserDataServiceImpl implements UserDataService {
  // Constants for keys
  static const String _authTokenKey = 'auth_token';

  static const String _roleKey = 'user_type';

  static const String _userEmailKey = 'user_email';

  static const String _userIdKey = 'user_id';
  static const String _emailVerifiedKey = 'email_verified';
  static const String _hasProfileKey = 'has_profile';
  static const String _profileCompletedKey = 'profile_completed';
  // New keys for profile data
  static const String _fullNameKey = 'full_name';
  static const String _phoneNumberKey = 'phone_number';
  static const String _occupationKey = 'occupation';

  static const String _organizationKey = 'organization';
  static const String _genderKey = 'gender';
  static const String _nationalityKey = 'nationality';
  static const String _regionKey = 'region';
  static const String _cityKey = 'city';
  static const String _woredaKey = 'woreda';
  static const String _idNumberKey = 'id_number';
  static const String _departmentKey = 'department';
  static const String _industryKey = 'industry';
  static const String _yearsOfExperienceKey = 'years_of_experience';
  static const String _photoPathKey = 'photo_path';
  final SharedPreferences sharedPreferences;
  UserDataServiceImpl({required this.sharedPreferences});
  @override
  Future<void> clearAllData() async {
    await sharedPreferences.remove(_authTokenKey);
    await sharedPreferences.remove(_roleKey);
    await sharedPreferences.remove(_userEmailKey);
    await sharedPreferences.remove(_userIdKey);
    await sharedPreferences.remove(_emailVerifiedKey);
    await sharedPreferences.remove(_hasProfileKey);
    await sharedPreferences.remove(_profileCompletedKey);

    // Remove all new profile data keys
    await sharedPreferences.remove(_fullNameKey);
    await sharedPreferences.remove(_phoneNumberKey);
    await sharedPreferences.remove(_occupationKey);
    await sharedPreferences.remove(_organizationKey);
    await sharedPreferences.remove(_genderKey);
    await sharedPreferences.remove(_nationalityKey);
    await sharedPreferences.remove(_regionKey);
    await sharedPreferences.remove(_cityKey);
    await sharedPreferences.remove(_woredaKey);
    await sharedPreferences.remove(_idNumberKey);
    await sharedPreferences.remove(_departmentKey);
    await sharedPreferences.remove(_industryKey);
    await sharedPreferences.remove(_yearsOfExperienceKey);
    await sharedPreferences.remove(_photoPathKey);
  }

  @override
  Future<AuthenticationStatus> getAuthenticationStatus() async {
    final token = await getAuthToken();
    final role = await getRole();
    final email = await getUserEmail();
    final userId = await getUserId();
    final isEmailVerified = await getEmailVerified();
    final hasProfile = await getHasProfile();
    final isProfileCompleted = await getProfileCompleted();

    final isAuthenticated = token != null && token.isNotEmpty;

    return AuthenticationStatus(
      isAuthenticated: isAuthenticated,
      token: token,
      role: role,
      email: email,
      userId: userId,
      isEmailVerified: isEmailVerified,
      hasProfile: hasProfile,
      isProfileCompleted: isProfileCompleted,
    );
  }

  @override
  Future<String?> getAuthToken() async {
    return sharedPreferences.getString(_authTokenKey);
  }

  @override
  Future<User?> getCachedUser() async {
    try {
      // Retrieve core user data
      final userId = await getUserId();
      final userEmail = await getUserEmail();
      final role = await getRole();

      // If any core data is missing, we cannot construct a valid user
      debugPrint(
        "core data of cached user: userId: ${userId ?? "null"}, userEmail: ${userEmail ?? "null"}, userRole: ${role ?? "null"}",
      );
      if (userId == null || userEmail == null || role == null) {
        return null;
      }

      // Retrieve all profile fields using the new getters
      final fullName = await getFullName();
      final phoneNumber = await getPhoneNumber();
      final occupation = await getOccupation();
      final organization = await getOrganization();
      final gender = await getGender();
      final nationality = await getNationality();
      final region = await getRegion();
      final city = await getCity();
      final woreda = await getWoreda();
      final idNumber = await getIdNumber();
      final hasProfile = await getHasProfile();
      final department = await getDepartment();
      final industry = await getIndustry();
      final yearsOfExperience = await getYearsOfExperience();
      final photoPath = await getPhotoPath();

      // Reconstruct and return the User object
      return User(
        id: userId,
        email: userEmail,
        role: role,
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
      );
    } catch (e) {
      // Log the error and return null if data retrieval fails
      // debugPrint("Error getting cached user: $e");
      return null;
    }
  }

  @override
  Future<String?> getCity() async {
    return sharedPreferences.getString(_cityKey);
  }

  @override
  Future<String?> getDepartment() async {
    return sharedPreferences.getString(_departmentKey);
  }

  @override
  Future<bool> getEmailVerified() async {
    return sharedPreferences.getBool(_emailVerifiedKey) ?? false;
  }

  // --- Profile Getters ---
  @override
  Future<String?> getFullName() async {
    return sharedPreferences.getString(_fullNameKey);
  }

  @override
  Future<String?> getGender() async {
    return sharedPreferences.getString(_genderKey);
  }

  @override
  Future<bool> getHasProfile() async {
    return sharedPreferences.getBool(_hasProfileKey) ?? false;
  }

  @override
  Future<String?> getIdNumber() async {
    return sharedPreferences.getString(_idNumberKey);
  }

  @override
  Future<String?> getIndustry() async {
    return sharedPreferences.getString(_industryKey);
  }

  @override
  Future<String?> getNationality() async {
    return sharedPreferences.getString(_nationalityKey);
  }

  @override
  Future<String?> getOccupation() async {
    return sharedPreferences.getString(_occupationKey);
  }

  @override
  Future<String?> getOrganization() async {
    return sharedPreferences.getString(_organizationKey);
  }

  @override
  Future<String?> getPhoneNumber() async {
    return sharedPreferences.getString(_phoneNumberKey);
  }

  @override
  Future<String?> getPhotoPath() async {
    return sharedPreferences.getString(_photoPathKey);
  }

  @override
  Future<bool> getProfileCompleted() async {
    return sharedPreferences.getBool(_profileCompletedKey) ?? false;
  }

  @override
  Future<String?> getRegion() async {
    return sharedPreferences.getString(_regionKey);
  }

  @override
  Future<String?> getRole() async {
    return sharedPreferences.getString(_roleKey);
  }

  @override
  Future<String?> getUserEmail() async {
    return sharedPreferences.getString(_userEmailKey);
  }

  @override
  Future<String?> getUserId() async {
    return sharedPreferences.getString(_userIdKey);
  }

  @override
  Future<String?> getUserRole() async => sharedPreferences.getString(_roleKey);

  @override
  Future<String?> getWoreda() async {
    return sharedPreferences.getString(_woredaKey);
  }

  @override
  Future<int?> getYearsOfExperience() async {
    return sharedPreferences.getInt(_yearsOfExperienceKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    debugPrint("in user data service, checking authenticated status: ");
    AuthenticationStatus authStat = await getAuthenticationStatus();
    debugPrint(
      "auth datas: {hasProfile: ${authStat.hasProfile}, isAuthed: ${authStat.hasProfile}, isProfileCompleted: ${authStat.isProfileCompleted}}",
    );

    return authStat.isAuthenticated &&
        (authStat.role != "participant" || authStat.hasProfile);
  }

  @override
  Future<void> setAuthToken(String token) async {
    await sharedPreferences.setString(_authTokenKey, token);
  }

  @override
  Future<void> setCity(String city) async {
    await sharedPreferences.setString(_cityKey, city);
  }

  @override
  Future<void> setDepartment(String department) async {
    await sharedPreferences.setString(_departmentKey, department);
  }

  @override
  Future<void> setEmailVerified(bool isVerified) async {
    await sharedPreferences.setBool(_emailVerifiedKey, isVerified);
  }

  // --- Profile Setters ---
  @override
  Future<void> setFullName(String fullName) async {
    await sharedPreferences.setString(_fullNameKey, fullName);
  }

  @override
  Future<void> setGender(String gender) async {
    await sharedPreferences.setString(_genderKey, gender);
  }

  @override
  Future<void> setHasProfile(bool hasProfile) async {
    await sharedPreferences.setBool(_hasProfileKey, hasProfile);
  }

  @override
  Future<void> setIdNumber(String idNumber) async {
    await sharedPreferences.setString(_idNumberKey, idNumber);
  }

  @override
  Future<void> setIndustry(String industry) async {
    await sharedPreferences.setString(_industryKey, industry);
  }

  @override
  Future<void> setNationality(String nationality) async {
    await sharedPreferences.setString(_nationalityKey, nationality);
  }

  @override
  Future<void> setOccupation(String occupation) async {
    await sharedPreferences.setString(_occupationKey, occupation);
  }

  @override
  Future<void> setOrganization(String organization) async {
    await sharedPreferences.setString(_organizationKey, organization);
  }

  @override
  Future<void> setPhoneNumber(String phoneNumber) async {
    await sharedPreferences.setString(_phoneNumberKey, phoneNumber);
  }

  @override
  Future<void> setPhotoPath(String photoPath) async {
    await sharedPreferences.setString(_photoPathKey, photoPath);
  }

  @override
  Future<void> setProfileCompleted(bool isCompleted) async {
    await sharedPreferences.setBool(_profileCompletedKey, isCompleted);
  }

  @override
  Future<void> setRegion(String region) async {
    await sharedPreferences.setString(_regionKey, region);
  }

  @override
  Future<void> setRole(String role) async {
    await sharedPreferences.setString(_roleKey, role);
  }

  @override
  Future<void> setUserEmail(String email) async {
    await sharedPreferences.setString(_userEmailKey, email);
  }

  @override
  Future<void> setUserId(String userId) async {
    await sharedPreferences.setString(_userIdKey, userId);
  }

  @override
  Future<void> setUserRole(String role) async =>
      sharedPreferences.setString(_roleKey, role);
  @override
  Future<void> setWoreda(String woreda) async {
    await sharedPreferences.setString(_woredaKey, woreda);
  }

  @override
  Future<void> setYearsOfExperience(int years) async {
    await sharedPreferences.setInt(_yearsOfExperienceKey, years);
  }
}
