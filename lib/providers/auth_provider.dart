// ----------------------------------------
// lib/providers/auth_provider.dart
// Provedor para la gestión del estado de autenticación.
// ----------------------------------------
import 'package:flutter/material.dart';
import '/models/auth_response.dart';
import '/models/user.dart';
import '/services/api_service.dart';
import '/services/auth_service.dart';
import 'dart:developer' as developer;

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    final token = await ApiService.getAccessToken();
    if (token != null) {
      try {
        await fetchUserAndSetState();
        developer.log('Usuario autenticado al inicio.', name: 'AuthProvider');
      } catch (e) {
        developer.log(
          'Error al verificar autenticación: $e. Forzando logout.',
          name: 'AuthProvider',
        );
        // En caso de error, el token es inválido o expiró
        await logout();
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final AuthResponse authResponse = await AuthService.login(
        email, // Usar email
        password,
      );
      await ApiService.saveTokens(authResponse.access, authResponse.refresh);
      await fetchUserAndSetState();
      developer.log('Login exitoso para ${email}.', name: 'AuthProvider');
    } catch (e) {
      _isAuthenticated = false;
      developer.log('Error en login: $e', name: 'AuthProvider');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserAndSetState() async {
    try {
      _user = await AuthService.fetchUserProfile();
      _isAuthenticated = true;
      developer.log(
        'Perfil de usuario cargado: ${_user?.username}',
        name: 'AuthProvider',
      );
    } catch (e) {
      developer.log(
        'Error al cargar perfil de usuario: $e',
        name: 'AuthProvider',
      );
      _isAuthenticated = false;
      _user = null;
      await ApiService.deleteTokens(); // Limpiar tokens si el perfil no se puede cargar
      rethrow;
    }
  }

  Future<void> logout() async {
    await ApiService.deleteTokens();
    _isAuthenticated = false;
    _user = null;
    developer.log('Sesión cerrada.', name: 'AuthProvider');
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> userData) async {
    try {
      // La API espera los campos de persona directamente en el objeto 'persona' anidado
      // y los campos de usuario en el nivel superior.
      // Aquí asumimos que userData ya viene con la estructura correcta para el PATCH.
      // Si userData contiene campos de usuario (ej. username, correo_electronico)
      // y campos de persona (ej. nombre, apellido), se deben separar.
      // Para el endpoint /me/, el UsuarioSerializer maneja la persona anidada.
      // Entonces, el `userData` debe ser un mapa que contenga la clave 'persona'
      // con sus campos anidados, y otros campos de usuario directamente.

      // Ejemplo de cómo debería ser userData para la API:
      // {
      //   'username': 'nuevo_username', // Opcional
      //   'correo_electronico': 'nuevo@email.com', // Opcional
      //   'persona': {
      //     'nombre': 'Nuevo Nombre',
      //     'apellido': 'Nuevo Apellido',
      //     'telefono': '123456789',
      //     'direccion': 'Nueva Direccion',
      //     'cedula': '1234567890' // Opcional
      //   }
      // }

      await AuthService.updateProfile(userData);
      await fetchUserAndSetState(); // Recargar el perfil después de la actualización
      notifyListeners(); // Notificar a los listeners sobre el cambio
      developer.log('Perfil actualizado y recargado.', name: 'AuthProvider');
    } catch (e) {
      developer.log(
        'Error al actualizar perfil en AuthProvider: $e',
        name: 'AuthProvider',
      );
      rethrow;
    }
  }
}
