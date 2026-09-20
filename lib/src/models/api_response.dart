import 'package:meta/meta.dart';

/// Represents a response received from an HTTP request.
///
/// [T] represents the type of the decoded response [data].
@immutable
class ApiResponse<T> {
  /// The decoded response payload, or `null` if the response body was empty.
  final T? data;

  /// The HTTP status code of the response (e.g. 200, 201, 204).
  final int statusCode;

  /// The HTTP response headers received from the server.
  final Map<String, String> headers;

  /// Creates a new [ApiResponse] instance.
  const ApiResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
  });

  /// Returns `true` if the status code indicates a successful response (200-299).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  @override
  String toString() =>
      'ApiResponse<$T>(statusCode: $statusCode, data: $data, headers: $headers)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponse<T> &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          data == other.data;

  @override
  int get hashCode => Object.hash(statusCode, data);
}
