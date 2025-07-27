// lib/core/error/exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final String code;

  const AppException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => '$runtimeType: $message (Code: $code)';
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    required super.code,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    required super.code,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    required super.code,
  });
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    required super.code,
    this.errors,
  });

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

class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    required super.code,
  });
}

class AuthorizationException extends AppException {
  const AuthorizationException({
    required super.message,
    required super.code,
  });
}

class FileException extends AppException {
  const FileException({
    required super.message,
    required super.code,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    required super.code,
  });
}

class ParseException extends AppException {
  const ParseException({
    required super.message,
    required super.code,
  });
}
