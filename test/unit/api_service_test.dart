// test/unit/api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_final/services/api_service.dart';
import 'package:flutter_final/config/api_config.dart';

// Generar mocks
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  late ApiService apiService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService();
    // Note: In a real scenario, you'd inject the mock client
  });

  group('ApiService Tests', () {
    test('should return valid endpoint URL', () {
      final endpoint = ApiConfig.getEndpoint('test/path');
      expect(endpoint, 'https://proyecto-2026-ts4b.onrender.com/test/path');
    });

    test('should handle endpoint with leading slash', () {
      final endpoint = ApiConfig.getEndpoint('/test/path');
      expect(endpoint, 'https://proyecto-2026-ts4b.onrender.com/test/path');
    });

    test('should have correct base URL', () {
      expect(ApiConfig.baseUrl, 'https://proyecto-2026-ts4b.onrender.com');
    });

    test('should have correct API version', () {
      expect(ApiConfig.apiVersion, 'v1');
    });

    test('should have correct timeout', () {
      expect(ApiConfig.requestTimeout, 30);
    });
  });
}