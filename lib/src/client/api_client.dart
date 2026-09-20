import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import 'api_client_impl.dart';

/// A lightweight, clean, and reusable REST API client for Dart and Flutter.
///
/// Example:
/// ```dart
/// final api = ApiClient(
///   baseUrl: 'https://api.example.com/api/v1',
/// );
///
/// final response = await api.get('/users');
/// print(response.statusCode);
/// print(response.data);
/// ```
abstract class ApiClient {
  /// Creates a new [ApiClient] instance.
  ///
  /// - [baseUrl]: The base endpoint for all API requests (e.g. `https://api.example.com/api/v1`).
  /// - [defaultHeaders]: Headers sent with every request unless overridden.
  /// - [timeout]: Default timeout for requests. Defaults to 30 seconds.
  /// - [httpClient]: Optional [http.Client] to use for requests. Useful for testing and custom client configuration.
  factory ApiClient({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    Duration timeout,
    http.Client? httpClient,
  }) = ApiClientImpl;

  /// The base URL for all relative requests.
  String get baseUrl;

  /// The default timeout duration for requests.
  Duration get timeout;

  /// Returns the current Bearer token, or `null` if none is set.
  String? get token;

  /// Sets the Bearer token to be included in subsequent requests.
  ///
  /// Requests will automatically include:
  /// `Authorization: Bearer <token>`
  void setToken(String token);

  /// Clears the Bearer token.
  ///
  /// Subsequent requests will no longer include the `Authorization` header
  /// unless explicitly passed in request-specific headers.
  void clearToken();

  /// Sends an HTTP GET request to [path].
  ///
  /// - [path]: Relative path (e.g. `/users`) or full URL.
  /// - [queryParameters]: Query parameters added to the request URL.
  /// - [headers]: Request-specific headers (overrides [defaultHeaders]).
  /// - [timeout]: Request-specific timeout (overrides default [timeout]).
  /// - [decoder]: Optional callback to transform decoded JSON into a typed model [T].
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  });

  /// Sends an HTTP POST request to [path].
  ///
  /// - [path]: Relative path or full URL.
  /// - [body]: Request body. Maps and Lists are automatically encoded to JSON.
  /// - [queryParameters]: Query parameters added to the request URL.
  /// - [headers]: Request-specific headers (overrides [defaultHeaders]).
  /// - [timeout]: Request-specific timeout (overrides default [timeout]).
  /// - [decoder]: Optional callback to transform decoded JSON into a typed model [T].
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  });

  /// Sends an HTTP PUT request to [path].
  ///
  /// - [path]: Relative path or full URL.
  /// - [body]: Request body. Maps and Lists are automatically encoded to JSON.
  /// - [queryParameters]: Query parameters added to the request URL.
  /// - [headers]: Request-specific headers (overrides [defaultHeaders]).
  /// - [timeout]: Request-specific timeout (overrides default [timeout]).
  /// - [decoder]: Optional callback to transform decoded JSON into a typed model [T].
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  });

  /// Sends an HTTP PATCH request to [path].
  ///
  /// - [path]: Relative path or full URL.
  /// - [body]: Request body. Maps and Lists are automatically encoded to JSON.
  /// - [queryParameters]: Query parameters added to the request URL.
  /// - [headers]: Request-specific headers (overrides [defaultHeaders]).
  /// - [timeout]: Request-specific timeout (overrides default [timeout]).
  /// - [decoder]: Optional callback to transform decoded JSON into a typed model [T].
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  });

  /// Sends an HTTP DELETE request to [path].
  ///
  /// - [path]: Relative path or full URL.
  /// - [body]: Optional request body. Maps and Lists are automatically encoded to JSON.
  /// - [queryParameters]: Query parameters added to the request URL.
  /// - [headers]: Request-specific headers (overrides [defaultHeaders]).
  /// - [timeout]: Request-specific timeout (overrides default [timeout]).
  /// - [decoder]: Optional callback to transform decoded JSON into a typed model [T].
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic json)? decoder,
  });

  /// Closes the underlying HTTP client and frees associated resources.
  void close();
}
