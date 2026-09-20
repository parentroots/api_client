// ignore_for_file: avoid_print

import 'package:api_client/api_client.dart';

/// Example data model for typed responses.
class User {
  final int id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}

Future<void> main() async {
  // 1. Initialize ApiClient with a base URL and configuration
  final api = ApiClient(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    timeout: const Duration(seconds: 15),
    defaultHeaders: {
      'Accept': 'application/json',
    },
  );

  try {
    // 2. Simple GET request with query parameters
    print('--- Fetching users ---');
    final response = await api.get<dynamic>(
      '/users',
      queryParameters: {
        '_limit': '2',
      },
    );

    print('Status: ${response.statusCode}');
    print('Response data: ${response.data}');

    // 3. Typed response using custom decoder
    print('\n--- Fetching single user with typed model ---');
    final userResponse = await api.get<User>(
      '/users/1',
      decoder: (dynamic json) => User.fromJson(json as Map<String, dynamic>),
    );
    print('User name: ${userResponse.data?.name}');
    print('User email: ${userResponse.data?.email}');

    // 4. Authenticated request using Bearer token
    print('\n--- Setting authentication token ---');
    api.setToken('sample-jwt-token-12345');

    // 5. POST request with automatic JSON serialization
    print('\n--- Creating a new post ---');
    final createPostResponse = await api.post<dynamic>(
      '/posts',
      body: {
        'title': 'Dart Packages',
        'body': 'Building clean REST clients in Dart.',
        'userId': 1,
      },
    );
    print('Post created with status: ${createPostResponse.statusCode}');
    print('Created post: ${createPostResponse.data}');

    // 6. Clear authentication token
    api.clearToken();
  } on UnauthorizedException catch (e) {
    print('Unauthorized: ${e.message} (status: ${e.statusCode})');
  } on NotFoundException catch (e) {
    print('Resource not found: ${e.message}');
  } on NetworkException catch (e) {
    print('Network connection failed: ${e.message}');
  } on ApiTimeoutException catch (e) {
    print('Request timed out: ${e.message}');
  } on ApiException catch (e) {
    print('API error [${e.statusCode}]: ${e.message}');
  } finally {
    // Clean up resources when done
    api.close();
  }
}
