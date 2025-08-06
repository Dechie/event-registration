// lib/features/verification/data/repositories/verification_repository.dart

import 'package:dartz/dartz.dart';
import 'package:event_reg/features/verification/data/datasource/verification_datasource.dart';
import 'package:flutter/material.dart' show debugPrint;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../models/verification_response.dart';

abstract class VerificationRepository {
  Future<Either<Failure, VerificationResponse>> verifyBadge(String badgeNumber);
}

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VerificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, VerificationResponse>> verifyBadge(String badgeNumber) async {
    try {
      debugPrint('📡 Repository: Verifying badge $badgeNumber');

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        debugPrint('❌ No internet connection');
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NO_INTERNET',
        ));
      }

      // Call remote data source
      final response = await remoteDataSource.verifyBadge(badgeNumber);
      debugPrint('✅ Repository: Verification successful');
      
      return Right(response);

    } on ValidationException catch (e) {
      debugPrint('❌ Repository: Validation error - ${e.message}');
      return Left(ValidationFailure(
        message: e.message,
        code: e.code,
        errors: e.errors,
      ));
    } on AuthenticationException catch (e) {
      debugPrint('❌ Repository: Authentication error - ${e.message}');
      return Left(AuthenticationFailure(
        message: e.message,
        code: e.code,
      ));
    } on AuthorizationException catch (e) {
      debugPrint('❌ Repository: Authorization error - ${e.message}');
      return Left(AuthorizationFailure(
        message: e.message,
        code: e.code,
      ));
    } on ServerException catch (e) {
      debugPrint('❌ Repository: Server error - ${e.message}');
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on NetworkException catch (e) {
      debugPrint('❌ Repository: Network error - ${e.message}');
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } on TimeoutException catch (e) {
      debugPrint('❌ Repository: Timeout error - ${e.message}');
      return Left(TimeoutFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e, stackTrace) {
      debugPrint('❌ Repository: Unexpected error - $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      return Left(UnknownFailure(
        message: 'An unexpected error occurred during verification. Please try again.',
        code: 'UNEXPECTED_REPOSITORY_ERROR',
      ));
    }
  }
}