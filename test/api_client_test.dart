import 'dart:async';
import 'dart:convert';

import 'package:clean_api_client/clean_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('ApiClient', () {
    test('GET request successfully parses JSON response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'https://api.example.com/api/v1/users',
        );
        return http.Response(
          jsonEncode([
            {'id': 1, 'name': 'John'},
            {'id': 2, 'name': 'Jane'},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com/api/v1',
        httpClient: mockClient,
      );

      final response = await api.get<dynamic>('/users');

      expect(response.statusCode, 200);
      expect(response.isSuccess, isTrue);
      expect(response.data, isA<List<dynamic>>());
      final list = response.data as List<dynamic>;
      expect(list.length, 2);
      expect((list[0] as Map<String, dynamic>)['name'], 'John');
    });

    test(
        'POST request with Map automatically encodes JSON body and sets content-type',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://api.example.com/api/v1/users',
        );
        expect(
          request.headers['content-type'],
          'application/json; charset=utf-8',
        );
        final decodedBody = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decodedBody['name'], 'Alice');
        expect(decodedBody['email'], 'alice@example.com');

        return http.Response(
          jsonEncode({'id': 10, 'name': 'Alice', 'email': 'alice@example.com'}),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com/api/v1/',
        httpClient: mockClient,
      );

      final response = await api.post<dynamic>(
        '/users',
        body: {'name': 'Alice', 'email': 'alice@example.com'},
      );

      expect(response.statusCode, 201);
      expect((response.data as Map<String, dynamic>)['id'], 10);
    });

    test('PUT request sends correct method and body', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.toString(), 'https://api.example.com/users/1');
        final decodedBody = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decodedBody['role'], 'admin');

        return http.Response(
          jsonEncode({'id': 1, 'role': 'admin'}),
          200,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      final response = await api.put<dynamic>(
        '/users/1',
        body: {'role': 'admin'},
      );

      expect(response.statusCode, 200);
      expect((response.data as Map<String, dynamic>)['role'], 'admin');
    });

    test('PATCH request sends correct method and body', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.toString(), 'https://api.example.com/users/1');
        final decodedBody = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decodedBody['status'], 'active');

        return http.Response(
          jsonEncode({'id': 1, 'status': 'active'}),
          200,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      final response = await api.patch<dynamic>(
        '/users/1',
        body: {'status': 'active'},
      );

      expect(response.statusCode, 200);
      expect((response.data as Map<String, dynamic>)['status'], 'active');
    });

    test('DELETE request sends correct method and query parameters', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(
          request.url.toString(),
          'https://api.example.com/users/1?force=true',
        );

        return http.Response(
          jsonEncode({'deleted': true}),
          200,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      final response = await api.delete<dynamic>(
        '/users/1',
        queryParameters: {'force': true},
      );

      expect(response.statusCode, 200);
      expect((response.data as Map<String, dynamic>)['deleted'], true);
    });

    test('handles query parameters and URL encoding', () async {
      final mockClient = MockClient((request) async {
        expect(
          request.url.queryParameters['search'],
          'john & doe',
        );
        expect(request.url.queryParameters['page'], '1');
        return http.Response('[]', 200);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      await api.get<dynamic>(
        '/users',
        queryParameters: {
          'search': 'john & doe',
          'page': 1,
        },
      );
    });

    test('handles default headers and custom header overrides', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['x-default-app'], 'my-app');
        expect(request.headers['accept'], 'application/vnd.custom+json');
        return http.Response('{}', 200);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        defaultHeaders: {
          'x-default-app': 'my-app',
          'Accept': 'application/json',
        },
        httpClient: mockClient,
      );

      await api.get<dynamic>(
        '/test',
        headers: {
          'Accept': 'application/vnd.custom+json',
        },
      );
    });

    test('manages Bearer token lifecycle with setToken and clearToken',
        () async {
      String? receivedAuthHeader;

      final mockClient = MockClient((request) async {
        receivedAuthHeader = request.headers['authorization'];
        return http.Response('{}', 200);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      // Initially no token
      expect(api.token, isNull);
      await api.get<dynamic>('/profile');
      expect(receivedAuthHeader, isNull);

      // Set token
      api.setToken('test-secret-token');
      expect(api.token, 'test-secret-token');
      await api.get<dynamic>('/profile');
      expect(receivedAuthHeader, 'Bearer test-secret-token');

      // Clear token
      api.clearToken();
      expect(api.token, isNull);
      await api.get<dynamic>('/profile');
      expect(receivedAuthHeader, isNull);
    });

    test('empty response body returns null data (e.g. 204 No Content)',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 204);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      final response = await api.delete<dynamic>('/items/1');

      expect(response.statusCode, 204);
      expect(response.data, isNull);
    });

    test('maps 401 response to UnauthorizedException with response data',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Invalid credentials'}),
          401,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => api.get<dynamic>('/secret'),
        throwsA(
          isA<UnauthorizedException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', 'Invalid credentials')
              .having(
                  (e) => (e.responseData as Map<String, dynamic>)['message'],
                  'responseData',
                  'Invalid credentials'),
        ),
      );
    });

    test('maps 403 response to ForbiddenException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Access denied'}),
          403,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => api.get<dynamic>('/admin'),
        throwsA(
          isA<ForbiddenException>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.message, 'message', 'Access denied'),
        ),
      );
    });

    test('maps 404 response to NotFoundException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Resource not found', 404);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => api.get<dynamic>('/missing'),
        throwsA(
          isA<NotFoundException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', 'Resource not found'),
        ),
      );
    });

    test('maps 400 response to BadRequestException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Validation failed'}),
          400,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => api.post<dynamic>('/users', body: <String, dynamic>{}),
        throwsA(
          isA<BadRequestException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'Validation failed'),
        ),
      );
    });

    test('maps 500 response to ServerException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Internal server error occurred'}),
          500,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => api.get<dynamic>('/crash'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message',
                  'Internal server error occurred'),
        ),
      );
    });

    test('maps ClientException to NetworkException', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Failed to connect to host');
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => api.get<dynamic>('/offline'),
        throwsA(
          isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Network error')),
        ),
      );
    });

    test('maps request timeout to ApiTimeoutException', () async {
      final mockClient = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{}', 200);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        timeout: const Duration(milliseconds: 10),
        httpClient: mockClient,
      );

      expect(
        () => api.get<dynamic>('/slow'),
        throwsA(isA<ApiTimeoutException>()),
      );
    });

    test('supports per-request timeout override', () async {
      final mockClient = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('{"status": "ok"}', 200);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        // Global timeout is very short (5ms)
        timeout: const Duration(milliseconds: 5),
        httpClient: mockClient,
      );

      // But per-request timeout is long enough (200ms)
      final response = await api.get<dynamic>(
        '/slow-ok',
        timeout: const Duration(milliseconds: 200),
      );

      expect(response.statusCode, 200);
      expect((response.data as Map<String, dynamic>)['status'], 'ok');
    });

    test('supports typed model parsing via decoder callback', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'id': 42, 'title': 'Test Post'}),
          200,
        );
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      final response = await api.get<_TestPost>(
        '/posts/42',
        decoder: (dynamic json) =>
            _TestPost.fromJson(json as Map<String, dynamic>),
      );

      expect(response.data, isA<_TestPost>());
      expect(response.data?.id, 42);
      expect(response.data?.title, 'Test Post');
    });

    test('handles non-JSON plain string response when T is dynamic or String',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response('Plain text response', 200);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      final response = await api.get<String>('/text');
      expect(response.data, 'Plain text response');
    });

    test(
        'throws ApiException when response is invalid JSON and expected type is typed model',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response('Invalid JSON content', 200);
      });

      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => api.get<_TestPost>(
          '/invalid-json',
          decoder: (dynamic json) =>
              _TestPost.fromJson(json as Map<String, dynamic>),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Failed to decode response as JSON'),
          ),
        ),
      );
    });

    test('close closes the underlying client without error', () {
      final mockClient = MockClient((request) async => http.Response('', 200));
      final api = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );
      expect(api.close, returnsNormally);
    });
  });
}

class _TestPost {
  final int id;
  final String title;

  _TestPost({required this.id, required this.title});

  factory _TestPost.fromJson(Map<String, dynamic> json) {
    return _TestPost(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}
