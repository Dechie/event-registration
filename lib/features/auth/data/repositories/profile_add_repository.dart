// features/auth/data/repositories/profile_add_repository.dart

import 'package:event_reg/core/error/exceptions.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/features/auth/data/datasource/profile_remote_datasource.dart';
import 'package:event_reg/features/auth/data/models/user.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileAddRepository {
  Future<Either<Failure, Map<String, dynamic>>> createProfile({
    required String token,
    required Map<String, dynamic> profileData,
  });
  
  Future<Either<Failure, User>> updateProfile({
    required String token,
    required Map<String, dynamic> profileData,
  });
  
  Future<Either<Failure, User>> getProfile({required String token});
}

class ProfileAddRepositoryImpl implements ProfileAddRepository {
  final ProfileRemoteDatasource profileRemoteDatasource;

  ProfileAddRepositoryImpl({required this.profileRemoteDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> createProfile({
    required String token,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final result = await profileRemoteDatasource.createProfile(
        token: token,
        profileData: profileData,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(
        message: "An unexpected error occurred",
        code: "UNKNOWN_ERROR",
      ));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String token,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final result = await profileRemoteDatasource.updateProfile(
        token: token,
        profileData: profileData,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(
        message: "An unexpected error occurred",
        code: "UNKNOWN_ERROR",
      ));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile({required String token}) async {
    try {
      final result = await profileRemoteDatasource.getProfile(token);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, code: e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(
        message: "An unexpected error occurred", 
        code: "UNKNOWN_ERROR",
      ));
    }
  }
}

// For easy access in AuthBloc, create a simplified version that returns direct results
class ProfileAddRepositorySimple {
  final ProfileRemoteDatasource profileRemoteDatasource;

  ProfileAddRepositorySimple({required this.profileRemoteDatasource});

  Future<Map<String, dynamic>> createProfile({
    required String token,
    required Map<String, dynamic> profileData,
  }) async {
    return await profileRemoteDatasource.createProfile(
      token: token,
      profileData: profileData,
    );
  }

  Future<User> updateProfile({
    required String token,
    required Map<String, dynamic> profileData,
  }) async {
    return await profileRemoteDatasource.updateProfile(
      token: token,
      profileData: profileData,
    );
  }

  Future<User> getProfile({required String token}) async {
    return await profileRemoteDatasource.getProfile(token);
  }
}