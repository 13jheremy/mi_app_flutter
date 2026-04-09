// ----------------------------------------
// lib/services/api_service.dart
// Servicio base para la comunicación con la API.
// Maneja los tokens de autorización y el refresco con protección de concurrencia.
// ----------------------------------------
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'package:synchronized/synchronized.dart';

class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Mutex para evitar múltiples refresh de token simultáneos
  static final Lock _tokenRefreshLock = Lock();
  static bool _isRefreshingToken = false;

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<Map<String, String>> getHeaders({bool withAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      String? token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        developer.log(
          '🔐 Token agregado a headers - primeros 20 chars: ${token.substring(0, token.length > 20 ? 20 : token.length)}',
          name: 'ApiService',
        );
      } else {
        developer.log(
          '⚠️ No hay token disponible para esta solicitud',
          name: 'ApiService',
        );
      }
    }
    return headers;
  }

  // Método para refrescar el token de acceso CON PROTECCIÓN DE CONCURRENCIA
  static Future<bool> _refreshAccessToken() async {
    // Usar mutex para evitar múltiples refreshes simultáneos
    return await _tokenRefreshLock.synchronized(() async {
      // Si ya se está refrescando, esperar a que termine
      if (_isRefreshingToken) {
        developer.log(
          'Token refresh ya en progreso, esperando...',
          name: 'ApiService',
        );
        return true; // Asumir que otro thread lo hizo correctamente
      }

      _isRefreshingToken = true;

      try {
        final refreshToken = await getRefreshToken();
        if (refreshToken == null) {
          developer.log('No refresh token available.', name: 'ApiService');
          _isRefreshingToken = false;
          return false;
        }

        // Evitar doble slash en la URL
        final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh/');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': refreshToken}),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final newAccessToken = responseBody['access'];
          final newRefreshToken = responseBody['refresh'];
          await saveTokens(newAccessToken, newRefreshToken);
          developer.log('✓ Token refreshed successfully.', name: 'ApiService');
          _isRefreshingToken = false;
          return true;
        } else {
          developer.log(
            '✗ Failed to refresh token: ${response.statusCode}',
            name: 'ApiService',
          );
          await deleteTokens();
          _isRefreshingToken = false;
          return false;
        }
      } catch (e) {
        developer.log(
          '✗ Exception during token refresh: $e',
          name: 'ApiService',
        );
        await deleteTokens();
        _isRefreshingToken = false;
        return false;
      }
    });
  }

  // Método genérico para manejar solicitudes HTTP con reintento de token
  static Future<http.Response> _sendRequest(
    Future<http.Response> Function(Map<String, String>) requestBuilder, {
    bool withAuth = true,
    bool isRetry = false,
  }) async {
    final headers = await getHeaders(withAuth: withAuth);
    http.Response response;

    try {
      response = await requestBuilder(headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw Exception('Timeout: La solicitud tardó demasiado'),
      );
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }

    // Manejo de token expirado (401 Unauthorized)
    if (response.statusCode == 401 && withAuth && !isRetry) {
      developer.log(
        'Token expirado (401). Intentando refrescar token...',
        name: 'ApiService',
        level: 800,
      );
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        developer.log(
          'Token refrescado exitosamente. Reintentando solicitud original...',
          name: 'ApiService',
          level: 800,
        );
        // Reintentar la solicitud original con el nuevo token
        return _sendRequest(requestBuilder, withAuth: withAuth, isRetry: true);
      } else {
        developer.log(
          'Fallo al refrescar token. Sesión expirada.',
          name: 'ApiService',
          level: 1000,
        );
        // Si el refresh falla, el token es inválido o expiró, forzar logout
        // Esto debería ser manejado por el AuthProvider que escucha los cambios en el token
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
      }
    }

    return response;
  }

  static Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool withAuth = true, // Permitir POST sin autenticación (ej. login)
  }) async {
    // Asegurar que el endpoint no tenga slash inicial para evitar doble slash
    String cleanEndpoint = endpoint;
    if (endpoint.startsWith('/')) {
      cleanEndpoint = endpoint.substring(1);
    }
    return _sendRequest(
      (headers) => http.post(
        Uri.parse('${ApiConfig.baseUrl}/$cleanEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      ),
      withAuth: withAuth,
    );
  }

  static Future<http.Response> get(String endpoint) async {
    // Asegurar que el endpoint no tenga slash inicial para evitar doble slash
    String cleanEndpoint = endpoint;
    if (endpoint.startsWith('/')) {
      cleanEndpoint = endpoint.substring(1);
    }
    return _sendRequest(
      (headers) => http.get(
        Uri.parse('${ApiConfig.baseUrl}/$cleanEndpoint'),
        headers: headers,
      ),
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    // Asegurar que el endpoint no tenga slash inicial para evitar doble slash
    String cleanEndpoint = endpoint;
    if (endpoint.startsWith('/')) {
      cleanEndpoint = endpoint.substring(1);
    }
    return _sendRequest(
      (headers) => http.put(
        Uri.parse('${ApiConfig.baseUrl}/$cleanEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
  }

  static Future<http.Response> patch(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    // Asegurar que el endpoint no tenga slash inicial para evitar doble slash
    String cleanEndpoint = endpoint;
    if (endpoint.startsWith('/')) {
      cleanEndpoint = endpoint.substring(1);
    }
    return _sendRequest(
      (headers) => http.patch(
        Uri.parse('${ApiConfig.baseUrl}/$cleanEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    // Asegurar que el endpoint no tenga slash inicial para evitar doble slash
    String cleanEndpoint = endpoint;
    if (endpoint.startsWith('/')) {
      cleanEndpoint = endpoint.substring(1);
    }
    return _sendRequest(
      (headers) => http.delete(
        Uri.parse('${ApiConfig.baseUrl}/$cleanEndpoint'),
        headers: headers,
      ),
    );
  }
}
