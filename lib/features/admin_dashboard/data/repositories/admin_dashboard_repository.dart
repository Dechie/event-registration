import 'package:dartz/dartz.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasource/admin_dashboard_datasource.dart';
import '../models/admin_dashboard_data.dart';

abstract class AdminDashboardRepository {
  Future<Either<Failure, AdminDashboardData>> getDashboardData();
}

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final AdminDashboardDataSource dataSource;
  final NetworkInfo networkInfo;

  AdminDashboardRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AdminDashboardData>> getDashboardData() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internect connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      final dashboardResponse = await dataSource.getDashboardData();

      return Right(dashboardResponse);
    } on NetworkException catch (e) {
      debugPrint("Network error during admin dashboard: ${e.message}");

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      debugPrint("Server error during admin dashboard fetch: ${e.message}");

      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint("Unexpected error during admin dashboard fetch $e");

      return const Left(UnknownFailure());
    }
  }
}
