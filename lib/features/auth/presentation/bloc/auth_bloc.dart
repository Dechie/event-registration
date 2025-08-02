import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/features/auth/data/repositories/auth_repository.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RegisterUserEvent>(_onRegisterUser);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<ResendOTPEvent>(_onResendOTP);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.updateProfile(
        fullName: event.fullName,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        nationality: event.nationality,
        phoneNumber: event.phoneNumber,
        region: event.region,
        city: event.city,
        woreda: event.woreda,
        idNumber: event.idNumber,
        occupation: event.occupation,
        organization: event.organization,
        department: event.department,
        industry: event.industry,
        yearsOfExperience: event.yearsOfExperience,
        photoPath: event.photoPath,
      );

      result.fold(
        (failure) {
          emit(
            AuthErrorState(
              message: _mapFailureToMessage(failure),
              errorCode: failure.codel,
            ),
          );
        },
        (updatedUser) {
          emit(
            AuthenticatedState(
              userId: updatedUser.id,
              email: updatedUser.email,
              userType: updatedUser.userType,
              userData: updatedUser.toJson(),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        const AuthErrorState(
          message: "Failed to update profile. Please try again",
          errorCode: "UPDATE_PROFILE_ERROR",
        ),
      );
    }
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

      // OTP errors:
      case "INVALID_OTP":
        return "Invalid OTP code. Please check and try again";
      case "OTP_EXPIRED":
        return "OTP code has expired. Please request a new one.";
      case "OTP_RATE_LIMIT_EXCEEDED":
      case "RATE_LIMIT_EXCEEDED":
        return "Too many requests. Please wait before tring again";

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
            : "An error occured. Please try again.";
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.getCurrentUser();

      result.fold(
        (failure) {
          emit(const UnauthenticatedState());
        },
        (user) {
          if (user != null) {
            emit(
              AuthenticatedState(
                userId: user.id,
                email: user.email,
                userType: user.userType,
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

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
        userType: event.userType,
        rememberMe: event.rememberMe,
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
          emit(
            AuthenticatedState(
              userId: loginResponse.user.id,
              email: loginResponse.user.email,
              userType: loginResponse.user.userType,
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

  Future<void> _onVerifyOTP(
    VerifyOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

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
          emit(AuthOTPVerifiedState(message: message, email: event.email));
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
