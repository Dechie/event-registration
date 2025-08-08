// lib/features/admin_dashboard/presentation/bloc/admin_dashboard_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/admin_dashboard_data.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardData dashboardData;

  const AdminDashboardLoaded(this.dashboardData);

  @override
  List<Object?> get props => [dashboardData];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
