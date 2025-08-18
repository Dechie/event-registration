// lib/features/admin_dashboard/presentation/bloc/admin_dashboard_bloc.dart

import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_dashboard_repository.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminDashboardRepository repository;

  AdminDashboardBloc({required this.repository})
    : super(AdminDashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(AdminDashboardLoading());
    debugPrint("reached admin dashboard's loadDashboard data");
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (dashboardData) => emit(AdminDashboardLoaded(dashboardData)),
    );
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    // Don't show loading state for refresh, just update data
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (dashboardData) => emit(AdminDashboardLoaded(dashboardData)),
    );
  }
}
