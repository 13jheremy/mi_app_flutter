// test/unit/auth_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_final/providers/auth_provider.dart';
import 'package:flutter_final/services/auth_service.dart';
import 'package:flutter_final/models/auth_response.dart';
import 'package:flutter_final/models/user.dart';

// Generar mocks
@GenerateMocks([AuthService])
import 'auth_provider_test.mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider();
  });

  group('AuthProvider Tests', () {
    test('Initial state should be loading', () {
      expect(authProvider.isLoading, true);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
    });

    test('Login success should update state', () async {
      // Arrange
      final authResponse = AuthResponse(
        access: 'access_token',
        refresh: 'refresh_token',
        user: User(id: 1, email: 'test@example.com', username: 'testuser'),
      );

      when(mockAuthService.login('test@example.com', 'password'))
          .thenAnswer((_) async => authResponse);

      // Act
      await authProvider.login('test@example.com', 'password');

      // Assert
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user?.email, 'test@example.com');
      expect(authProvider.isLoading, false);
    });

    test('Login failure should handle error', () async {
      // Arrange
      when(mockAuthService.login('test@example.com', 'wrong_password'))
          .thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => authProvider.login('test@example.com', 'wrong_password'),
        throwsException,
      );
      expect(authProvider.isLoading, false);
    });

    test('Logout should clear user data', () async {
      // Arrange - Set up authenticated state first
      authProvider = AuthProvider(); // Reset provider

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
    });
  });
}