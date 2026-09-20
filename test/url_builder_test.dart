import 'package:api_client/src/utils/url_builder.dart';
import 'package:test/test.dart';

void main() {
  group('UrlBuilder', () {
    test('handles trailing slash on baseUrl and leading slash on path', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com/api/v1/',
        path: '/users',
      );
      expect(uri.toString(), 'https://api.example.com/api/v1/users');
    });

    test('handles no trailing slash on baseUrl and no leading slash on path',
        () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com/api/v1',
        path: 'users',
      );
      expect(uri.toString(), 'https://api.example.com/api/v1/users');
    });

    test('handles multiple trailing and leading slashes safely', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com/api/v1///',
        path: '///users///',
      );
      expect(uri.toString(), 'https://api.example.com/api/v1/users///');
    });

    test('handles empty path by returning baseUrl', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com/api/v1',
        path: '',
      );
      expect(uri.toString(), 'https://api.example.com/api/v1');
    });

    test('handles root slash path by returning baseUrl', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com/api/v1/',
        path: '/',
      );
      expect(uri.toString(), 'https://api.example.com/api/v1');
    });

    test('preserves absolute URLs passed in path', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com/api/v1',
        path: 'https://external-service.com/webhook',
      );
      expect(uri.toString(), 'https://external-service.com/webhook');
    });

    test('correctly URL-encodes query parameters', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com',
        path: '/search',
        queryParameters: {
          'query': 'dart & flutter',
          'limit': 10,
          'page': '2',
        },
      );
      expect(
        uri.toString(),
        'https://api.example.com/search?query=dart+%26+flutter&limit=10&page=2',
      );
    });

    test('ignores null query parameter values', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com',
        path: '/users',
        queryParameters: {
          'active': 'true',
          'filter': null,
        },
      );
      expect(uri.toString(), 'https://api.example.com/users?active=true');
    });

    test('handles iterable query parameter values', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com',
        path: '/items',
        queryParameters: {
          'tag': ['mobile', 'web'],
        },
      );
      expect(
        uri.toString(),
        'https://api.example.com/items?tag=mobile&tag=web',
      );
    });

    test('merges existing query parameters in path with new parameters', () {
      final uri = UrlBuilder.buildUri(
        baseUrl: 'https://api.example.com',
        path: '/users?sort=asc',
        queryParameters: {
          'page': '1',
        },
      );
      expect(
        uri.toString(),
        'https://api.example.com/users?sort=asc&page=1',
      );
    });
  });
}
