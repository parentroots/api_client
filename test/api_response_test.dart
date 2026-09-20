import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('ApiResponse', () {
    test('instantiates correctly with data, statusCode, and headers', () {
      const response = ApiResponse<Map<String, dynamic>>(
        data: {'name': 'John'},
        statusCode: 200,
        headers: {'content-type': 'application/json'},
      );

      expect(response.data, {'name': 'John'});
      expect(response.statusCode, 200);
      expect(response.headers, {'content-type': 'application/json'});
      expect(response.isSuccess, isTrue);
    });

    test('isSuccess returns true for 2xx status codes and false otherwise', () {
      expect(
        const ApiResponse(data: null, statusCode: 200, headers: {}).isSuccess,
        isTrue,
      );
      expect(
        const ApiResponse(data: null, statusCode: 201, headers: {}).isSuccess,
        isTrue,
      );
      expect(
        const ApiResponse(data: null, statusCode: 204, headers: {}).isSuccess,
        isTrue,
      );
      expect(
        const ApiResponse(data: null, statusCode: 301, headers: {}).isSuccess,
        isFalse,
      );
      expect(
        const ApiResponse(data: null, statusCode: 400, headers: {}).isSuccess,
        isFalse,
      );
      expect(
        const ApiResponse(data: null, statusCode: 500, headers: {}).isSuccess,
        isFalse,
      );
    });

    test('equality and hashCode work as expected', () {
      const res1 = ApiResponse<String>(
        data: 'success',
        statusCode: 200,
        headers: {'a': '1'},
      );
      const res2 = ApiResponse<String>(
        data: 'success',
        statusCode: 200,
        headers: {'a': '1'},
      );
      const res3 = ApiResponse<String>(
        data: 'other',
        statusCode: 200,
        headers: {'a': '1'},
      );

      expect(res1, equals(res2));
      expect(res1.hashCode, equals(res2.hashCode));
      expect(res1, isNot(equals(res3)));
    });

    test('toString contains statusCode, data, and headers', () {
      const response = ApiResponse<String>(
        data: 'test',
        statusCode: 200,
        headers: {'x-custom': 'val'},
      );

      final str = response.toString();
      expect(str, contains('statusCode: 200'));
      expect(str, contains('data: test'));
      expect(str, contains('headers: {x-custom: val}'));
    });
  });
}
