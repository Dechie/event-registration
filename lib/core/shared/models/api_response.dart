// import 'package:equatable/equatable.dart';

// class ApiResponse extends Equatable {
//   final bool success;
//   final String message;
//   final T? data;
//   final Map<String, dynamic> errors;
//   final int? statusCode;

//   const ApiResponse({
//     required this.success,
//     required this.message,
//     this.data,
//     this.errors = const {},
//     this.statusCode,
//   });

//   factory ApiRespose.fromJson(
//     Map<String, dynamic> json,
//     T Function(Map<String, dynamic>)? fromJsonT,
//   ) {
//     return ApiResponse<T>(
//       success: json['success'] ?? true,
//       message: json["message"] ?? '',
//       data: json["data"] != null && fromJsonT != null
//           ? fromJsonT(json["data"])
//           : json["data"],
//       errors: json["errors"],
//       statusCode: json["status_code"],
//     );
//   }

//   @override
//   List<Object?> get props => [success, message, data, errors, statusCode];
// }
