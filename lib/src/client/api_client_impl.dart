import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/api_exception.dart';
import '../models/api_response.dart';
import '../utils/url_builder.dart';
import 'api_client.dart';

/// Default implementation of [ApiClient] using Dart's `package:http`.
class ApiClientImpl implements ApiClient {
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;
  final Duration _timeout;
  final http.Client _client;

  String? _token;

  /// Creates a new [ApiClientImpl] instance.
  ApiClientImpl({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    Duration timeout = const Duration(seconds: 30),
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _defaultHeaders = defaultHeaders != null
            ? Map<String, String>.from(defaultHeaders)
            : <String, String>{},
        _timeout = timeout,
        _client = httpClient ?? http.Client();

  @override
  String get baseUrl => _baseUrl;

  @override
  Duration get timeout => _timeout;

  @override
  String? get token => _token;

  @override
  void setToken(String token) {
    _token = token;
  }

  @override
  void clearToken() {
    _token = null;
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  }) {
    return _send<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  }) {
    return _send<T>(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  }) {
    return _send<T>(
      'PUT',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  }) {
    return _send<T>(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  }) {
    return _send<T>(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
      decoder: decoder,
    );
  }

  @override
  void close() {
    _client.close();
  }

  Future<ApiResponse<T>> _send<T>(
    String method,
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  }) async {
    final uri = UrlBuilder.buildUri(
      baseUrl: _baseUrl,
      path: path,
      queryParameters: queryParameters,
    );

    final isJsonBody = body != null && (body is Map || body is List);
    final resolvedHeaders = _buildHeaders(headers, isJsonBody: isJsonBody);
    final encodedBody = _encodeBody(body);

    final request = http.Request(method, uri);
    request.headers.addAll(resolvedHeaders);

    if (encodedBody != null) {
      if (encodedBody is String) {
        request.body = encodedBody;
      } else if (encodedBody is List<int>) {
        request.bodyBytes = encodedBody;
      }
    }

    final effectiveTimeout = timeout ?? _timeout;
    http.Response response;

    try {
      final streamedResponse =
          await _client.send(request).timeout(effectiveTimeout);
      response = await http.Response.fromStream(streamedResponse);
    } on TimeoutException catch (e, stackTrace) {
      throw ApiTimeoutException(
        message:
            'Request to $uri timed out after ${effectiveTimeout.inSeconds}s.',
        uri: uri,
        innerException: e,
        stackTrace: stackTrace,
      );
    } on http.ClientException catch (e, stackTrace) {
      throw NetworkException(
        message:
            'Network error occurred while connecting to $uri: ${e.message}',
        uri: uri,
        innerException: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;

      if (e.toString().contains('SocketException')) {
        throw NetworkException(
          message: 'Network error occurred while connecting to $uri: $e',
          uri: uri,
          innerException: e,
          stackTrace: stackTrace,
        );
      }

      throw ApiException(
        message: 'An unexpected error occurred while requesting $uri: $e',
        uri: uri,
        innerException: e,
        stackTrace: stackTrace,
      );
    }

    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final parsedData = _decodeResponseBody<T>(response, decoder);
      return ApiResponse<T>(
        data: parsedData,
        statusCode: statusCode,
        headers: response.headers,
      );
    }

    _handleErrorResponse(response);
  }

  Map<String, String> _buildHeaders(
    Map<String, String>? requestHeaders, {
    required bool isJsonBody,
  }) {
    final result = <String, String>{};

    // 1. Copy default headers
    result.addAll(_defaultHeaders);

    // 2. Apply Bearer token if present and not already defined
    final currentToken = _token;
    if (currentToken != null && currentToken.isNotEmpty) {
      _setHeaderIfNotPresent(result, 'Authorization', 'Bearer $currentToken');
    }

    // 3. Apply JSON Content-Type if body is JSON and not already defined
    if (isJsonBody) {
      _setHeaderIfNotPresent(
        result,
        'Content-Type',
        'application/json; charset=utf-8',
      );
    }

    // 4. Merge request-specific headers, overriding any previous values case-insensitively
    if (requestHeaders != null) {
      for (final entry in requestHeaders.entries) {
        _setHeader(result, entry.key, entry.value);
      }
    }

    return result;
  }

  void _setHeader(Map<String, String> headers, String key, String value) {
    final lowerKey = key.toLowerCase();
    headers.removeWhere((k, _) => k.toLowerCase() == lowerKey);
    headers[key] = value;
  }

  void _setHeaderIfNotPresent(
    Map<String, String> headers,
    String key,
    String value,
  ) {
    final lowerKey = key.toLowerCase();
    final alreadyPresent = headers.keys.any((k) => k.toLowerCase() == lowerKey);
    if (!alreadyPresent) {
      headers[key] = value;
    }
  }

  Object? _encodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body;
    if (body is List<int>) return body;
    if (body is Map || body is List || body is num || body is bool) {
      return jsonEncode(body);
    }
    try {
      return jsonEncode(body);
    } catch (_) {
      return body.toString();
    }
  }

  T? _decodeResponseBody<T>(
    http.Response response,
    T Function(dynamic json)? decoder,
  ) {
    final body = response.body;
    if (body.isEmpty || response.statusCode == 204) {
      return null;
    }

    dynamic decodedJson;
    try {
      decodedJson = jsonDecode(body);
    } on FormatException {
      // If response is not JSON (e.g. plain text, HTML, etc.)
      if (T == String || T == dynamic) {
        return body as T?;
      }
      throw ApiException(
        message: 'Failed to decode response as JSON.',
        statusCode: response.statusCode,
        responseData: body,
        uri: response.request?.url,
      );
    }

    if (decoder != null) {
      return decoder(decodedJson);
    }

    if (T == dynamic || T == Object) {
      return decodedJson as T?;
    }

    try {
      return decodedJson as T?;
    } catch (e, stackTrace) {
      throw ApiException(
        message: 'Failed to cast response data to expected type $T: $e',
        statusCode: response.statusCode,
        responseData: decodedJson,
        uri: response.request?.url,
        innerException: e,
        stackTrace: stackTrace,
      );
    }
  }

  Never _handleErrorResponse(http.Response response) {
    final body = response.body;
    dynamic responseData;
    if (body.isNotEmpty) {
      try {
        responseData = jsonDecode(body);
      } on FormatException {
        responseData = body;
      }
    }

    String message;
    if (responseData is Map) {
      final msg = responseData['message'] ??
          responseData['error'] ??
          responseData['detail'] ??
          responseData['title'];
      message = msg?.toString() ??
          'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Request failed'}';
    } else if (responseData is String && responseData.trim().isNotEmpty) {
      message = responseData.trim();
    } else {
      message =
          'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Request failed'}';
    }

    throw ApiException.fromStatusCode(
      statusCode: response.statusCode,
      message: message,
      responseData: responseData,
      uri: response.request?.url,
    );
  }
}
