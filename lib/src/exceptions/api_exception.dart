import 'package:meta/meta.dart';

/// Base class for all exceptions thrown by the `api_client` package.
@immutable
class ApiException implements Exception {
  /// A human-readable message describing the error.
  final String message;

  /// The HTTP status code associated with this error, if available.
  final int? statusCode;

  /// The parsed response body or error payload from the server, if available.
  final dynamic responseData;

  /// The request URI that triggered this exception, if available.
  final Uri? uri;

  /// The underlying exception or error, if available.
  final Object? innerException;

  /// The stack trace associated with the original error, if available.
  final StackTrace? stackTrace;

  /// Creates an [ApiException] instance.
  const ApiException({
    required this.message,
    this.statusCode,
    this.responseData,
    this.uri,
    this.innerException,
    this.stackTrace,
  });

  /// Factory constructor that creates the appropriate [ApiException] subclass
  /// based on the given HTTP [statusCode].
  factory ApiException.fromStatusCode({
    required int statusCode,
    required String message,
    dynamic responseData,
    Uri? uri,
    Object? innerException,
    StackTrace? stackTrace,
  }) {
    if (statusCode == 400) {
      return BadRequestException(
        message: message,
        statusCode: statusCode,
        responseData: responseData,
        uri: uri,
        innerException: innerException,
        stackTrace: stackTrace,
      );
    } else if (statusCode == 401) {
      return UnauthorizedException(
        message: message,
        statusCode: statusCode,
        responseData: responseData,
        uri: uri,
        innerException: innerException,
        stackTrace: stackTrace,
      );
    } else if (statusCode == 403) {
      return ForbiddenException(
        message: message,
        statusCode: statusCode,
        responseData: responseData,
        uri: uri,
        innerException: innerException,
        stackTrace: stackTrace,
      );
    } else if (statusCode == 404) {
      return NotFoundException(
        message: message,
        statusCode: statusCode,
        responseData: responseData,
        uri: uri,
        innerException: innerException,
        stackTrace: stackTrace,
      );
    } else if (statusCode >= 500 && statusCode < 600) {
      return ServerException(
        message: message,
        statusCode: statusCode,
        responseData: responseData,
        uri: uri,
        innerException: innerException,
        stackTrace: stackTrace,
      );
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      responseData: responseData,
      uri: uri,
      innerException: innerException,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType');
    if (statusCode != null) {
      buffer.write(' ($statusCode)');
    }
    buffer.write(': $message');
    if (uri != null) {
      buffer.write('\nURI: $uri');
    }
    if (responseData != null) {
      buffer.write('\nResponse: $responseData');
    }
    if (innerException != null) {
      buffer.write('\nCaused by: $innerException');
    }
    return buffer.toString();
  }
}

/// Thrown when a network connectivity issue or socket failure occurs.
class NetworkException extends ApiException {
  /// Creates a [NetworkException].
  const NetworkException({
    required super.message,
    super.uri,
    super.innerException,
    super.stackTrace,
  });
}

/// Thrown when an HTTP request exceeds its configured timeout duration.
class ApiTimeoutException extends ApiException {
  /// Creates an [ApiTimeoutException].
  const ApiTimeoutException({
    required super.message,
    super.uri,
    super.innerException,
    super.stackTrace,
  });
}

/// Thrown when the server returns a 400 Bad Request status code.
class BadRequestException extends ApiException {
  /// Creates a [BadRequestException].
  const BadRequestException({
    required super.message,
    super.statusCode = 400,
    super.responseData,
    super.uri,
    super.innerException,
    super.stackTrace,
  });
}

/// Thrown when the server returns a 401 Unauthorized status code.
class UnauthorizedException extends ApiException {
  /// Creates an [UnauthorizedException].
  const UnauthorizedException({
    required super.message,
    super.statusCode = 401,
    super.responseData,
    super.uri,
    super.innerException,
    super.stackTrace,
  });
}

/// Thrown when the server returns a 403 Forbidden status code.
class ForbiddenException extends ApiException {
  /// Creates a [ForbiddenException].
  const ForbiddenException({
    required super.message,
    super.statusCode = 403,
    super.responseData,
    super.uri,
    super.innerException,
    super.stackTrace,
  });
}

/// Thrown when the server returns a 404 Not Found status code.
class NotFoundException extends ApiException {
  /// Creates a [NotFoundException].
  const NotFoundException({
    required super.message,
    super.statusCode = 404,
    super.responseData,
    super.uri,
    super.innerException,
    super.stackTrace,
  });
}

/// Thrown when the server returns a 5xx Server Error status code.
class ServerException extends ApiException {
  /// Creates a [ServerException].
  const ServerException({
    required super.message,
    super.statusCode,
    super.responseData,
    super.uri,
    super.innerException,
    super.stackTrace,
  });
}
