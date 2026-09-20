/// Utility class for safely constructing and formatting URIs for API requests.
class UrlBuilder {
  UrlBuilder._();

  /// Builds a normalized [Uri] from [baseUrl], [path], and optional [queryParameters].
  ///
  /// - Safely eliminates duplicate or missing slashes between [baseUrl] and [path].
  /// - Supports absolute URLs if passed in [path].
  /// - Safely merges and URL-encodes [queryParameters], preserving any parameters
  ///   already present in [path].
  static Uri buildUri({
    required String baseUrl,
    required String path,
    Map<String, dynamic>? queryParameters,
  }) {
    final pathUri = Uri.tryParse(path);
    final isAbsolute =
        pathUri != null && pathUri.hasScheme && pathUri.host.isNotEmpty;

    String combinedUrl;
    if (isAbsolute) {
      combinedUrl = path;
    } else {
      final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
      final cleanPath = path.replaceAll(RegExp(r'^/+'), '');

      if (cleanBase.isEmpty) {
        combinedUrl = cleanPath.isEmpty ? '/' : cleanPath;
      } else if (cleanPath.isEmpty) {
        combinedUrl = cleanBase;
      } else {
        combinedUrl = '$cleanBase/$cleanPath';
      }
    }

    final parsedUri = Uri.parse(combinedUrl);

    if (queryParameters == null || queryParameters.isEmpty) {
      return parsedUri;
    }

    final queryParams = <String, dynamic>{};

    // Preserve existing query parameters from the path if any.
    parsedUri.queryParametersAll.forEach((key, values) {
      if (values.length == 1) {
        queryParams[key] = values.first;
      } else {
        queryParams[key] = values;
      }
    });

    // Merge in new query parameters, ignoring null values.
    queryParameters.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable) {
        queryParams[key] = value.map((dynamic e) => e.toString()).toList();
      } else {
        queryParams[key] = value.toString();
      }
    });

    return parsedUri.replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }
}
