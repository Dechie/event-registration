import 'package:event_reg/features/splash/lib/features/splash/data/models/auth_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/splash_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashRepository repository;

  SplashBloc({required this.repository}) : super(SplashInitial()) {
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
    on<InitializeApp>(_onInitializeApp);
  }

  Future<void> _onCheckAuthenticationStatus(
    CheckAuthenticationStatus event,
    Emitter<SplashState> emit,
  ) async {
    try {
      final authStatus = await repository.checkAuthenticationStatus();

      switch (authStatus.userType) {
        case UserType.participant:
          emit(SplashNavigateToParticipantDashboard(email: authStatus.email!));
          break;
        case UserType.admin:
          emit(SplashNavigateToAdminDashboard());
          break;
        case UserType.none:
      }
    } catch (e) {
      // If there's an error, navigate to landing page
      emit(SplashNavigateToLanding());
    }
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    // Simulate loading time for better UX
    await Future.delayed(const Duration(seconds: 2));

    // Check authentication status
    add(CheckAuthenticationStatus());
  }
}
