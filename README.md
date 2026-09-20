# clean_api_client

[![pub package](https://img.shields.io/pub/v/clean_api_client.svg)](https://pub.dev/packages/clean_api_client)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Dart SDK](https://img.shields.io/badge/Dart-3.0%2B-0175C2.svg)](https://dart.dev)

A lightweight, clean, and reusable REST API client for Dart and Flutter developers. Reduces repetitive HTTP boilerplate, manages headers and authentication tokens, automatically encodes/decodes JSON, and provides rich, typed error handling out of the box.

---

## Features

- ⚡ **Lightweight & Clean**: Built directly on top of the official `package:http` without unnecessary overhead.
- 🌐 **All Standard HTTP Methods**: Simple and consistent methods for `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`.
- 🔗 **Smart URL Builder**: Safely normalizes base URLs and paths—no duplicate slashes or missing slashes.
- 📦 **Automatic JSON Handling**: Automatic JSON serialization for request bodies and deserialization for response payloads.
- 🎯 **Generic & Typed Responses**: Get raw decoded objects or parse directly into domain models via `decoder`.
- 🔑 **Bearer Token Auth**: Built-in `setToken()` and `clearToken()` methods that manage the `Authorization` header automatically.
- 🛡️ **Comprehensive Exception Hierarchy**: Status codes mapped to typed exceptions (`UnauthorizedException`, `NotFoundException`, `ServerException`, etc.).
- ⏱️ **Configurable Timeouts**: Global and per-request timeout support with `ApiTimeoutException`.
- 🧪 **Easily Testable**: Supports dependency injection for `http.Client` for fast, 100% mocked unit tests.

---

## Installation

Add `clean_api_client` to your `pubspec.yaml`:

```yaml
dependencies:
  clean_api_client: ^0.1.0
```

Or run:

```bash
dart pub add clean_api_client
# or for Flutter projects:
flutter pub add clean_api_client
```

Import it in your Dart code:

```dart
import 'package:clean_api_client/clean_api_client.dart';
```

---

## Basic Setup

Instantiate `ApiClient` with your base URL and optional default configuration:

```dart
final api = ApiClient(
  baseUrl: 'https://api.example.com/api/v1',
  timeout: const Duration(seconds: 30),
  defaultHeaders: {
    'Accept': 'application/json',
    'X-App-Version': '1.0.0',
  },
);
```

### URL Normalization

`ApiClient` automatically sanitizes trailing and leading slashes:

- `https://api.example.com/api/v1/` + `/users` ➔ `https://api.example.com/api/v1/users`
- `https://api.example.com/api/v1` + `users` ➔ `https://api.example.com/api/v1/users`

---

## HTTP Methods

### GET Example

```dart
final response = await api.get('/users');

print('Status: ${response.statusCode}');
print('Data: ${response.data}');
```

### POST Example

`Map` and `List` bodies are automatically JSON-encoded and the `Content-Type: application/json` header is attached:

```dart
final response = await api.post(
  '/users',
  body: {
    'name': 'Jane Doe',
    'email': 'jane.doe@example.com',
  },
);

print('Created: ${response.data}');
```

### PUT Example

```dart
final response = await api.put(
  '/users/1',
  body: {
    'name': 'Jane Smith',
    'email': 'jane.smith@example.com',
  },
);

print('Updated: ${response.data}');
```

### PATCH Example

```dart
final response = await api.patch(
  '/users/1',
  body: {
    'name': 'Jane Updated',
  },
);

print('Patched: ${response.data}');
```

### DELETE Example

```dart
final response = await api.delete('/users/1');

print('Deleted with status: ${response.statusCode}');
```

---

## Query Parameters

Pass query parameters easily using a `Map<String, dynamic>`. They are automatically merged with any existing query parameters and URL-encoded:

```dart
final response = await api.get(
  '/users',
  queryParameters: {
    'page': 1,
    'limit': 20,
    'search': 'john doe',
    'status': ['active', 'verified'],
  },
);
```

Generated URL:
```
https://api.example.com/api/v1/users?page=1&limit=20&search=john+doe&status=active&status=verified
```

---

## Authentication

Manage Bearer tokens effortlessly:

```dart
// Set authentication token
api.setToken('your-jwt-access-token');

// All subsequent requests automatically include:
// Authorization: Bearer your-jwt-access-token
final profile = await api.get('/profile');

// Remove token when the user logs out
api.clearToken();
```

---

## Custom Headers

Configure global headers during initialization, or override them on a per-request basis:

```dart
// Request-specific header override
final response = await api.get(
  '/reports',
  headers: {
    'Accept': 'application/pdf',
    'Cache-Control': 'no-cache',
  },
);
```

---

## Response Handling

All methods return a strongly-typed `ApiResponse<T>`:

```dart
class ApiResponse<T> {
  final T? data;                 // Parsed JSON or decoded model
  final int statusCode;          // HTTP status code (200, 201, 204, etc.)
  final Map<String, String> headers; // Response headers
  bool get isSuccess;            // True when statusCode is 200..299
}
```

### Typed Responses with Decoders

Pass a `decoder` callback to parse the response payload directly into your domain models:

```dart
class User {
  final int id;
  final String name;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String;
}

// response.data is typed as User?
final response = await api.get<User>(
  '/users/1',
  decoder: (json) => User.fromJson(json as Map<String, dynamic>),
);

print(response.data?.name);
```

---

## Error Handling

`api_client` maps HTTP status codes and network issues to structured exceptions:

```dart
try {
  final response = await api.get('/protected-resource');
} on UnauthorizedException catch (e) {
  print('401 Unauthorized: ${e.message}');
  print('Server response: ${e.responseData}');
} on ForbiddenException catch (e) {
  print('403 Forbidden: ${e.message}');
} on NotFoundException catch (e) {
  print('404 Not Found: ${e.message}');
} on ServerException catch (e) {
  print('Server error [${e.statusCode}]: ${e.message}');
} on ApiTimeoutException catch (e) {
  print('Request timed out: ${e.message}');
} on NetworkException catch (e) {
  print('No internet or connection failed: ${e.message}');
} on ApiException catch (e) {
  print('General API error: ${e.message}');
}
```

### Exception Hierarchy

| Exception | Condition / HTTP Code |
|:---|:---|
| `NetworkException` | Connection failure, DNS error, or socket exception |
| `ApiTimeoutException` | Request exceeded timeout duration |
| `BadRequestException` | HTTP `400` Bad Request |
| `UnauthorizedException` | HTTP `401` Unauthorized |
| `ForbiddenException` | HTTP `403` Forbidden |
| `NotFoundException` | HTTP `404` Not Found |
| `ServerException` | HTTP `500`-`599` Server Error |
| `ApiException` | Base class for all API exceptions |

---

## Timeout Configuration

Configure a global timeout or override it per request:

```dart
// Global timeout
final api = ApiClient(
  baseUrl: 'https://api.example.com',
  timeout: const Duration(seconds: 10),
);

// Per-request override
final response = await api.get(
  '/heavy-report',
  timeout: const Duration(minutes: 2),
);
```

---

## Testing

You can mock HTTP responses without making any real network calls by supplying a mock client via `http.Client`:

```dart
import 'package:clean_api_client/clean_api_client.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test('fetches user successfully', () async {
    final mockClient = MockClient((request) async {
      return http.Response('{"name": "Alice"}', 200);
    });

    final api = ApiClient(
      baseUrl: 'https://api.example.com',
      httpClient: mockClient,
    );

    final response = await api.get('/users/1');
    expect(response.statusCode, 200);
    expect(response.data['name'], 'Alice');
  });
}
```

Run tests using:

```bash
dart test
```

---

## Resource Cleanup

When you are done with the client (for example, in a long-lived app's disposal lifecycle), call `close()`:

```dart
api.close();
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
