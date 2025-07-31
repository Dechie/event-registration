import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/features/auth/data/repositories/auth_repository.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<RegisterUserEvent>(_onRegisterUser);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<ResendOTPEvent>(_onResendOTP);
  }

  // String _mapFailureToMessage(Failure failure) {
  //   switch (failure.code) {
  //     case 'INVALID_CREDENTIALS':
  //       return 'Invalid email or password. Please check your credentials.';
  //     case 'USER_NOT_FOUND':
  //       return 'No account found with this email address.';
  //     case 'USER_DISABLED':
  //       return 'This account has been disabled. Please contact support.';
  //     case 'EMAIL_NOT_VERIFIED':
  //       return 'Please verify your email address before signing in.';
  //     case 'ACCOUNT_LOCKED':
  //       return 'Account temporarily locked due to multiple failed attempts.';
  //     case 'NETWORK_ERROR':
  //       return 'Network error. Please check your internet connection.';
  //     case 'SERVER_ERROR':
  //       return 'Server error. Please try again later.';
  //     case 'TIMEOUT_ERROR':
  //       return 'Request timeout. Please try again.';
  //     case 'TOKEN_EXPIRED':
  //       return 'Session expired. Please sign in again.';
  //     case 'INVALID_TOKEN':
  //       return 'Invalid session. Please sign in again.';
  //     default:
  //       return failure.message.isNotEmpty
  //           ? failure.message
  //           : 'An error occurred. Please try again.';
  //   }
  // }
  String _mapFailureToMessage(Failure failure) {
    switch (failure.code) {
      // Login errors
      case 'INVALID_CREDENTIALS':
        return 'Invalid email or password. Please check your credentials.';
      case 'USER_NOT_FOUND':
        return 'No account found with this email address.';
      case 'USER_DISABLED':
        return 'This account has been disabled. Please contact support.';
      case 'EMAIL_NOT_VERIFIED':
        return 'Please verify your email address before signing in.';
      case 'ACCOUNT_LOCKED':
        return 'Account temporarily locked due to multiple failed attempts.';

      // Registration errors
      case 'EMAIL_ALREADY_EXISTS':
        return 'An account with this email already exists. Please sign in or use a different email.';
      case 'REGISTRATION_FAILED':
        return 'Registration failed. Please check your details and try again.';
      case 'INVALID_REQUEST':
        return 'Invalid registration data. Please check your inputs.';

      // OTP errors
      case 'INVALID_OTP':
        return 'Invalid OTP code. Please check and try again.';
      case 'OTP_EXPIRED':
        return 'OTP code has expired. Please request a new one.';
      case 'OTP_RATE_LIMIT_EXCEEDED':
        return 'Too many OTP requests. Please wait before requesting again.';

      // Network errors
      case 'NETWORK_ERROR':
        return 'Network error. Please check your internet connection.';
      case 'TIMEOUT_ERROR':
        return 'Request timeout. Please try again.';

      // Server errors
      case 'SERVER_ERROR':
        return 'Server error. Please try again later.';
      case 'TOKEN_EXPIRED':
        return 'Session expired. Please sign in again.';
      case 'INVALID_TOKEN':
        return 'Invalid session. Please sign in again.';

      // Validation errors
      case 'VALIDATION_ERROR':
        if (failure is ValidationFailure && failure.errors != null) {
          // Return the first validation error message
          final errors = failure.errors!;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError.isNotEmpty) {
              return firstError.first.toString();
            }
            return firstError.toString();
          }
        }
        return 'Please check your input and try again.';

      default:
        return failure.message.isNotEmpty
            ? failure.message
            : 'An error occurred. Please try again.';
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

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.forgotPassword(event.email);

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
          emit(ForgotPasswordSuccessState(message: message));
        },
      );
    } catch (e) {
      emit(
        const AuthErrorState(
          message: 'Failed to send reset email. Please try again.',
          errorCode: 'FORGOT_PASSWORD_ERROR',
        ),
      );
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
      emit(
        AuthErrorState(
          message: 'An unexpected error occurred. Please try again.',
          errorCode: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.logout();

      result.fold(
        (failure) {
          // Even if logout fails on server, clear local state
          emit(const UnauthenticatedState());
        },
        (_) {
          emit(const UnauthenticatedState());
        },
      );
    } catch (e) {
      // Always logout locally even if server logout fails
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await authRepository.refreshToken();

      result.fold(
        (failure) {
          // If token refresh fails, user needs to login again
          emit(const UnauthenticatedState());
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
        const AuthErrorState(
          message: "Registration Failed. Please try again",
          errorCode: "REGISTRATION_ERROR",
        ),
      );
    }
  }

  Future<void> _onResendOTP(
    ResendOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
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
        AuthErrorState(
          message: "Failed to send OTP, please try again.",
          errorCode: "RESEND_OTP_ERROR",
        ),
      );
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final result = await authRepository.resetPassword(
        token: event.token,
        newPassword: event.newPassword,
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
          emit(PasswordResetSuccessState(message: message));
        },
      );
    } catch (e) {
      emit(
        const AuthErrorState(
          message: 'Failed to reset password. Please try again.',
          errorCode: 'RESET_PASSWORD_ERROR',
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
              errorCode: failure.errorCode,
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
          message: "OTP Verification Failed. Please try again",
          errorCode: "OTP_VERIFICATION_ERROR",
        ),
      );
    }
  }
}
