// ----------------------------------------
// lib/models/auth_response.dart
// Modelo para la respuesta de autenticación (JWT).
// ----------------------------------------
class AuthResponse {
  final String access;
  final String refresh;

  AuthResponse({required this.access, required this.refresh});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      access: json['access']?.toString() ?? '',
      refresh: json['refresh']?.toString() ?? '',
    );
  }
}
