/// A lightweight, clean, and reusable REST API client for Dart and Flutter.
///
/// To get started, instantiate [ApiClient] and make requests:
///
/// ```dart
/// import 'package:api_client/api_client.dart';
///
/// final api = ApiClient(baseUrl: 'https://api.example.com/api/v1');
///
/// final response = await api.get('/users');
/// print(response.statusCode);
/// print(response.data);
/// ```
library;

export 'src/client/api_client.dart' show ApiClient;
export 'src/exceptions/api_exception.dart'
    show
        ApiException,
        NetworkException,
        ApiTimeoutException,
        BadRequestException,
        UnauthorizedException,
        ForbiddenException,
        NotFoundException,
        ServerException;
export 'src/models/api_response.dart' show ApiResponse;
