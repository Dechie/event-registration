import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:event_reg/features/auth/data/repositories/auth_repository.dart';
import 'package:event_reg/features/auth/data/repositories/profile_add_repository.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final ProfileAddRepository profileRepository;
  final UserDataService userDataService;
  AuthBloc({
    required this.authRepository,
    required this.profileRepository,
    required this.userDataService,
  }) : super(AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RegisterUserEvent>(_onRegisterUser);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<ResendOTPEvent>(_onResendOTP);
    on<CreateProfileEvent>(_onCreateProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }
  String _mapFailureToMessage(Failure failure) {
    switch (failure.code) {
      // login errors:
      case "INVALID_CREDENTIALS":
        return "Invalid email or password. Please check your credentials";
      case "USER_NOT_FOUND":
      case "NOT_FOUND":
        return "No account found with this email address.";
      case "ACCESS_DENIED":
        return "Access denied. Please contact support";
      case "EMAIL_NOT_VERIFIED":
        return "Please verify your email address before signing in";
      case "ACCOUNT_LOCKED":
        return "Account temporarily locked due to multiple failed attempts.";

      // registration errors:
      case "EMAIL_ALREADY_EXISTS":
        return "An account with this email already exists, Please sign in or use a different email";
      case "REGISTRATION_FAILED":
      case "REGISTRATION_ERROR":
        return "Registration failed. Please check your details and try again.";

      // Profile errors:
      case "PROFILE_ALREADY_EXISTS":
        return "Profile already exists. You can update your existing profile instead.";
      case "CREATE_PROFILE_ERROR":
        return "Failed to create profile. Please check your details and try again.";
      case "UPDATE_PROFILE_ERROR":
        return "Failed to update profile. Please try again.";
      case "TOKEN_REQUIRED":
        return "Authentication required. Please sign in again.";

      // OTP errors:
      case "INVALID_OTP":
        return "Invalid OTP code. Please check and try again";
      case "OTP_EXPIRED":
        return "OTP code has expired. Please request a new one.";
      case "OTP_RATE_LIMIT_EXCEEDED":
      case "RATE_LIMIT_EXCEEDED":
        return "Too many requests. Please wait before trying again";

      // Network errors:
      case "NETWORK_ERROR":
        return "Network error. Please check your internet connection";
      case "NETWORK_TIMEOUT":
      case "TIMEOUT_ERROR":
        return "Request timeout. Please try again";
      // Server errors.
      case "SERVER_ERROR":
        return "Server error. Please try again later";
      case "TOKEN_EXPIRED":
        return "Session expired. Please sign in again";
      case "INVALID_TOKEN":
        return "Invalid session. Please sign in again.";

      // validation errors
      case "VALIDATION_ERROR":
        if (failure is ValidationFailure && failure.errors != null) {
          final errors = failure.errors!;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
        }
        return "Please check your input and try again";
      default:
        return failure.message.isNotEmpty
            ? failure.message
            : "An error occurred. Please try again.";
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await authRepository.getCurrentUser();

      result.fold(
        (failure) {
          emit(UnauthenticatedState());
        },
        (user) {
          if (user != null) {
            emit(
              AuthenticatedState(
                userId: user.id,
                email: user.email,
                role: user.role,
                userData: user.toJson(),
              ),
            );
          } else {
            emit(const UnauthenticatedState());
          }
        },
      );
    } catch (e) {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onCreateProfile(
    CreateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final token = await userDataService.getAuthToken();
      if (token == null) {
        emit(AuthErrorState(message: "Authentication token not found"));
        return;
      }

      final profileData = {
        'full_name': event.fullName,
        'gender': event.gender,
        'date_of_birth': event.dateOfBirth?.toIso8601String(),
        'nationality': event.nationality,
        'phone_number': event.phoneNumber,
        'region': event.region,
        'city': event.city,
        'woreda': event.woreda,
        'id_number': event.idNumber,
        'occupation': event.occupation,
        'organization': event.organization,
        'department': event.department,
        'industry': event.industry,
        'years_of_experience': event.yearsOfExperience,
        'photo': event.photoPath,
      };

      final result = await profileRepository.createProfile(
        token: token,
        profileData: profileData,
      );

      result.fold(
        (failure) {
          debugPrint(
            "Failed creating profile: ${failure.code}: ${failure.message}",
          );
          if (failure.message.contains("Profile already completed") ||
              failure.code.contains("PROFILE_ALREADY_EXISTS")) {
            emit(
              AuthProfileCreatedState(
                message: "Your Profile is already created.",
                userData: User.fromJson(profileData),
              ),
            );

            userDataService.setHasProfile(true);
          }
        },
        (obtainedResult) {
          emit(
            AuthProfileCreatedState(
              message:
                  obtainedResult['message'] ?? 'Profile created successfully',
              userData: User.fromJson(obtainedResult['participant']),
            ),
          );

          userDataService.setHasProfile(true);
        },
      );
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
        role: event.role,
      );

      result.fold(
        (failure) {
          emit(
            AuthErrorState(
              message: _mapFailureToMessage(failure),
              errorCode: failure.code,
            ),
          );
        },
        (loginResponse) {
          debugPrint(
            "at auth bloc: login successful. role: ${loginResponse.user.role}",
          );
          emit(
            AuthenticatedState(
              userId: loginResponse.user.id,
              email: loginResponse.user.email,
              role: loginResponse.user.role,
              token: loginResponse.token,
              userData: loginResponse.user.toJson(),
            ),
          );
        },
      );
    } catch (e) {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.logout();

      result.fold(
        (failure) {
          emit(const UnauthenticatedState());
        },
        (_) {
          emit(const UnauthenticatedState());
        },
      );
    } catch (e) {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.registerUser(
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
        role: event.role,
      );
      result.fold(
        (failure) {
          emit(
            AuthErrorState(
              message: _mapFailureToMessage(failure),
              errorCode: failure.code,
            ),
          );
        },
        (registrationResponse) {
          emit(
            AuthRegistrationSuccessState(
              message: registrationResponse.message,
              userId: registrationResponse.userId,
              email: registrationResponse.email,
              otpSent: registrationResponse.otpSent,
              otpToken: registrationResponse.otpToken,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        AuthErrorState(
          message: "Registration failed. Please try again.",
          errorCode: "REGISTRATION_ERROR",
        ),
      );
    }
  }

  Future<void> _onResendOTP(
    ResendOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.resendOTP(event.email);

      result.fold(
        (failure) {
          emit(
            AuthErrorState(
              message: _mapFailureToMessage(failure),
              errorCode: failure.code,
            ),
          );
        },
        (message) {
          emit(AuthOTPSentState(message: message, email: event.email));
        },
      );
    } catch (e) {
      emit(
        const AuthErrorState(
          message: "Failed to send OTP. Please try again",
          errorCode: "RESEND_OTP_ERROR",
        ),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final token = await userDataService.getAuthToken();
      if (token == null) {
        emit(AuthErrorState(message: "Authentication token not found"));
        return;
      }

      final profileData = {
        'fullName': event.fullName,
        'gender': event.gender,
        'dateOfBirth': event.dateOfBirth?.toIso8601String(),
        'nationality': event.nationality,
        'phoneNumber': event.phoneNumber,
        'region': event.region,
        'city': event.city,
        'woreda': event.woreda,
        'idNumber': event.idNumber,
        'occupation': event.occupation,
        'organization': event.organization,
        'department': event.department,
        'industry': event.industry,
        'yearsOfExperience': event.yearsOfExperience,
        'photoPath': event.photoPath,
      };

      final result = await profileRepository.updateProfile(
        token: token,
        profileData: profileData,
      );

      result.fold(
        (failure) {
          debugPrint("failed to update profile: ${failure.message}");
        },
        (obtainedResult) async {
          await userDataService.setHasProfile(true);
          emit(
            AuthProfileUpdatedState(
              message: 'Profile updated successfully',
              userData: obtainedResult.toJson(),
            ),
          );
        },
      );
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onVerifyOTP(
    VerifyOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await authRepository.verifyOTP(
        email: event.email,
        otp: event.otp,
        otpToken: event.otpToken,
      );

      result.fold(
        (failure) {
          emit(
            AuthErrorState(
              message: _mapFailureToMessage(failure),
              errorCode: failure.code,
            ),
          );
        },
        (message) {
          emit(
            AuthOTPVerifiedState(
              message: message,
              email: event.email,
              role: event.role,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        const AuthErrorState(
          message: "OTP verification failed. Please try again.",
          errorCode: "OTP_VERIFICATION_ERROR",
        ),
      );
    }
  }
}
