import 'package:dartz/dartz.dart';
import 'package:event_reg/core/error/failures.dart';
import 'package:event_reg/core/network/network_info.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, bool>> checkInParticipant(String qrCodeId);
  Future<Either<Failure, bool>> manualCheckIn(String email);
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> checkInParticipant(String qrCodeId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkInParticipant(qrCodeId);
        return Right(result);
      } catch (e) {
        return Left(
          ServerFailure(message: e.toString(), code: 'CHECK_IN_ERROR'),
        );
      }
    }
    return const Left(
      NetworkFailure(message: 'No internet connection', code: 'NETWORK_ERROR'),
    );
  }

  Future<Either<Failure, bool>> manualChekIn(String email) async {
    return Right<Failure, bool>(true);
  }
}
