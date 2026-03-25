// ----------------------------------------
// lib/config/api_config.dart
// Configuración de la URL base del backend.
// ----------------------------------------
class ApiConfig {
  // URL base del backend
  static const String baseUrl = 'https://proyecto-2026-ts4b.onrender.com';

  // Versión de la API
  static const String apiVersion = 'v1';

  // Timeout para solicitudes HTTP (en segundos)
  static const int requestTimeout = 30;

  // Número máximo de reintentos
  static const int maxRetries = 3;

  // Obtener endpoint completo con versión
  static String getEndpoint(String path) {
    // Quitar slash inicial si existe para evitar doble slash
    String cleanPath = path;
    if (path.startsWith('/')) {
      cleanPath = path.substring(1);
    }
    return '$baseUrl/$cleanPath';
  }
}
