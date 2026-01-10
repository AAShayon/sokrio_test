import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sokrio_people_pulse/app/core/di/service_locator.dart';

// Integration test to verify API key and network configuration
// This ensures our API client is properly set up before running other tests

void main() {
  group('API Configuration Tests', () {
    late Dio dio;

    setUpAll(() async {
      // Initialize service locator to set up DI
      await setupLocator();
      dio = locator<Dio>();
    });

    test('should have correct base URL configured', () {
      expect(dio.options.baseUrl, 'https://reqres.in/');
    });

    test('should have required headers configured', () {
      expect(dio.options.headers,
          containsPair('x-api-key', 'reqres_fe1d1ad0b1464121ac2bd248f1af79d0'));
      // Accept header may be null, that's ok
    });

    test('should have proper timeout configuration', () {
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    });

    test('should make successful API call to users endpoint', () async {
      final response = await dio
          .get('api/users', queryParameters: {'page': 1, 'per_page': 1});

      expect(response.statusCode, 200);
      expect(response.data, isA<Map>());
      expect(response.data['data'], isNotEmpty);

      final user = response.data['data'][0];
      expect(user['id'], isA<int>());
      expect(user['email'], isA<String>());
      expect(user['first_name'], isA<String>());
      expect(user['last_name'], isA<String>());
    });

    test('should handle 404 error gracefully', () async {
      try {
        await dio.get('nonexistent-endpoint');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<DioException>());
        final dioException = e as DioException;
        expect(dioException.response?.statusCode, 404);
      }
    });

    test('should have proper request interceptors configured', () {
      expect(dio.interceptors, isNotEmpty);
      // We expect at least logging interceptor and maybe auth interceptor
      expect(dio.interceptors.length, greaterThanOrEqualTo(1));
    });
  });
}
