# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.0

### Added
- Initial release of `api_client`.
- Support for `GET`, `POST`, `PUT`, `PATCH`, and `DELETE` HTTP methods.
- Clean `ApiResponse<T>` generic model with status code, headers, and parsed data.
- Robust URL builder with automatic leading and trailing slash normalization.
- Automatic query parameter encoding and serialization.
- Automatic JSON encoding for request bodies (`Map` / `List`).
- Automatic JSON decoding for response bodies.
- Bearer token authentication management with `setToken()` and `clearToken()`.
- Default header configuration and request-specific header overrides.
- Configurable global and per-request timeouts.
- Rich exception hierarchy (`ApiException`, `NetworkException`, `ApiTimeoutException`, `UnauthorizedException`, `ForbiddenException`, `NotFoundException`, `ServerException`, `BadRequestException`).
- Dependency injection support for `http.Client`.
