import 'package:event_reg/features/splash/data/models/auth_status.dart';
import 'package:flutter/material.dart';
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
      debugPrint("splash bloc: after check auth status:");
      debugPrint(
        "auth status: {token: ${authStatus.token} , email: ${authStatus.email}, usertype: ${authStatus.userType.name}}",
      );
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
    debugPrint("splash bloc: initialized");

    // Simulate loading time for better UX
    await Future.delayed(const Duration(seconds: 2));

    // Check authentication status
    debugPrint("splash bloc: added check auth status state");
    add(CheckAuthenticationStatus());
    debugPrint("splash bloc: checked auth status");
  }
}
