// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

class AttendanceAlreadyTakenFailure extends Failure {
  const AttendanceAlreadyTakenFailure({
    required super.message,
    required super.code,
  });
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, required super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, required super.code});
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required super.message, required super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, required super.code});
}

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({required this.message, required this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType: $message (Code: $code)';
}

class FileFailure extends Failure {
  const FileFailure({required super.message, required super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, required super.code});
}

class ParseFailure extends Failure {
  const ParseFailure({required super.message, required super.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.code});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, required super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code = 'UNKNOWN_ERROR',
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    required super.code,
    this.errors,
  });

  @override
  List<Object?> get props => [message, code, errors];

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorMessages = errors!.entries
          .map((e) => '${e.key}: ${e.value.join(', ')}')
          .join('; ');
      return '$runtimeType: $message ($errorMessages) (Code: $code)';
    }
    return super.toString();
  }
}

/// Represents a "not found" error.
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, required super.code});
}

/// Represents a business logic conflict error.
class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, required super.code});
}


