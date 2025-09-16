// lib/features/certificate/data/repositories/certificate_repository.dart
import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';
import 'package:event_reg/features/certificate/data/datasource/certificate_datasource.dart';
import 'package:event_reg/features/certificate/data/models/certificate.dart';
import 'package:flutter/material.dart' show debugPrint;

abstract class CertificateRepository {
  Future<Either<Failure, Certificate>> getCertificate(String badgeNumber);
  Future<Either<Failure, List<Certificate>>> getMyCertificates();
}

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateDataSource dataSource;
  final NetworkInfo networkInfo;

  CertificateRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Certificate>> getCertificate(
    String badgeNumber,
  ) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      debugPrint('📋 Repository: Fetching certificate for badge: $badgeNumber');

      final certificate = await dataSource.getCertificate(badgeNumber);

      debugPrint('✅ Repository: Certificate fetched successfully');

      return Right(certificate);
    } on NetworkException catch (e) {
      debugPrint('❌ Repository Network error: ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint('❌ Repository Auth error: ${e.message}');

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      debugPrint('❌ Repository Server error: ${e.message}');

      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Repository Unexpected error: $e');

      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Certificate>>> getMyCertificates() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: "No internet connection",
            code: "NETWORK_ERROR",
          ),
        );
      }

      debugPrint('📋 Repository: Fetching my certificates...');

      final certificates = await dataSource.getMyCertificates();

      debugPrint('✅ Repository: My certificates fetched successfully');

      return Right(certificates);
    } on NetworkException catch (e) {
      debugPrint('❌ Repository Network error: ${e.message}');

      return Left(NetworkFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      debugPrint('❌ Repository Auth error: ${e.message}');

      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      debugPrint('❌ Repository Server error: ${e.message}');

      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      debugPrint('❌ Repository Unexpected error: $e');

      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
