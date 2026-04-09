// ----------------------------------------
// lib/services/auth_service.dart
// Lógica para la autenticación y el perfil.
// ----------------------------------------
import 'dart:convert';
import '/models/user.dart';
import '/models/auth_response.dart';
import '/services/api_service.dart';
import 'dart:developer' as developer;

class AuthService {
  // 🔑 Login
  static Future<AuthResponse> login(String email, String password) async {
    try {
      // Usar 'correo_electronico' como username_field en la API
      final response = await ApiService.post(
        '/api/auth/mobile-login/',
        body: {'correo_electronico': email, 'password': password},
        withAuth: false, // Login no requiere autenticación previa
      );

      developer.log(
        'Login response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log(
        'Login response body: ${response.body}',
        name: 'AuthService',
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return AuthResponse.fromJson(responseBody);
      } else {
        String errorMessage = _parseLoginError(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Si ya es una excepción con mensaje, rethrow
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      // Manejar errores de red
      developer.log('Error en AuthService.login: $e', name: 'AuthService');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  // Método para parsear errores de login similar al frontend
  static String _parseLoginError(dynamic response) {
    String errorMessage;
    try {
      final errorBody = jsonDecode(response.body);
      final statusCode = response.statusCode;

      // Manejar según código de estado HTTP
      if (statusCode == 401) {
        // Verificar si hay mensajes específicos de lockout
        if (errorBody is Map && errorBody['locked'] == true) {
          errorMessage =
              errorBody['error'] ?? 'Cuenta bloqueada por demasiados intentos';
        } else if (errorBody is Map && errorBody['detail']) {
          errorMessage = errorBody['detail'].toString();
        } else {
          errorMessage = 'Usuario o contraseña incorrectos';
        }
      } else if (statusCode == 400) {
        if (errorBody is Map) {
          if (errorBody.containsKey('non_field_errors')) {
            errorMessage = (errorBody['non_field_errors'] as List).join(', ');
          } else if (errorBody.containsKey('correo_electronico')) {
            errorMessage = (errorBody['correo_electronico'] as List).join(', ');
          } else if (errorBody.containsKey('password')) {
            errorMessage = (errorBody['password'] as List).join(', ');
          } else if (errorBody.containsKey('detail')) {
            errorMessage = errorBody['detail'].toString();
          } else {
            final firstKey = errorBody.keys.first;
            final firstValue = errorBody[firstKey];
            errorMessage = firstValue is List
                ? firstValue.join(', ')
                : firstValue.toString();
          }
        } else {
          errorMessage = 'Datos de acceso inválidos';
        }
      } else if (statusCode == 403) {
        errorMessage = 'Cuenta desactivada o sin permisos';
      } else if (statusCode >= 500) {
        errorMessage = 'Error del servidor. Intenta más tarde';
      } else {
        // Para otros códigos, parsear el cuerpo genérico
        if (errorBody is Map) {
          if (errorBody.containsKey('detail')) {
            errorMessage = errorBody['detail'].toString();
          } else if (errorBody.containsKey('non_field_errors')) {
            errorMessage = (errorBody['non_field_errors'] as List).join(', ');
          } else {
            final firstKey = errorBody.keys.first;
            final firstValue = errorBody[firstKey];
            errorMessage = firstValue is List
                ? firstValue.join(', ')
                : firstValue.toString();
          }
        } else {
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'Error al iniciar sesión';
        }
      }
    } catch (_) {
      // Si no se puede parsear como JSON, usar el body como texto
      errorMessage = response.body.isNotEmpty
          ? response.body
          : 'Error de autenticación';
    }
    return errorMessage;
  }

  // 🔑 Obtener perfil del usuario logueado
  static Future<User?> fetchUserProfile() async {
    try {
      final response = await ApiService.get('/api/me/');

      developer.log(
        'fetchUserProfile response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log(
        'fetchUserProfile response body: ${response.body}',
        name: 'AuthService',
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return User.fromJson(responseBody);
      } else if (response.statusCode == 401) {
        throw Exception('Token de acceso expirado o inválido');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMessage = errorBody['detail'] ?? 'Error al cargar perfil';
        throw Exception('Error al cargar perfil: $errorMessage');
      }
    } catch (e) {
      developer.log(
        'Error en AuthService.fetchUserProfile: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }

  // 🔑 Actualizar perfil del usuario logueado
  static Future<void> updateProfile(Map<String, dynamic> userData) async {
    try {
      if (userData.isEmpty) {
        throw Exception('No hay datos para actualizar');
      }

      developer.log(
        'Actualizando perfil con datos: $userData',
        name: 'AuthService',
      );

      // Usar el endpoint PUT /api/personas/{id}/ para actualizar la persona
      // Primero necesitamos obtener el ID de la persona del usuario actual
      final currentUserResponse = await ApiService.get('/api/me/');
      if (currentUserResponse.statusCode != 200) {
        throw Exception('No se pudo obtener la información del usuario actual');
      }

      final currentUserData = jsonDecode(currentUserResponse.body);
      final personaId = currentUserData['persona']?['id'];

      if (personaId == null) {
        throw Exception('No se pudo obtener el ID de la persona');
      }

      // Usar PUT para actualizar completamente la persona
      final response = await ApiService.put(
        '/personas/$personaId/',
        body: userData,
      );

      developer.log(
        'updateProfile response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log(
        'updateProfile response body: ${response.body}',
        name: 'AuthService',
      );

      if (response.statusCode == 200) {
        developer.log('Perfil actualizado exitosamente', name: 'AuthService');
      } else if (response.statusCode == 401) {
        throw Exception('Token de acceso expirado o inválido');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Datos inválidos: ${errorBody.toString()}');
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMessage =
            errorBody['detail'] ?? 'Error al actualizar el perfil';
        throw Exception('Error al actualizar el perfil: $errorMessage');
      }
    } catch (e) {
      developer.log(
        'Error en AuthService.updateProfile: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }

  // 🔑 Cambiar contraseña (requiere Djoser)
  static Future<void> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      if (oldPassword.isEmpty || newPassword.isEmpty) {
        throw Exception('Las contraseñas no pueden estar vacías');
      }

      final response = await ApiService.post(
        '/api/me/cambiar-password/', // Endpoint correcto del backend
        body: {'old_password': oldPassword, 'new_password': newPassword},
      );

      developer.log(
        'changePassword response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log(
        'changePassword response body: ${response.body}',
        name: 'AuthService',
      );

      if (response.statusCode == 204) {
        // Djoser devuelve 204 No Content para éxito
        developer.log('Contraseña cambiada exitosamente', name: 'AuthService');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        // Djoser puede devolver errores específicos como {'current_password': ['Invalid password.']}
        String errorMessage = 'Error en los datos';
        if (errorBody is Map && errorBody.containsKey('current_password')) {
          errorMessage = errorBody['current_password'][0];
        } else if (errorBody is Map && errorBody.containsKey('new_password')) {
          errorMessage = errorBody['new_password'][0];
        } else if (errorBody is Map && errorBody.containsKey('detail')) {
          errorMessage = errorBody['detail'];
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception('Contraseña actual incorrecta o sesión expirada');
      } else {
        throw Exception('Error al cambiar contraseña');
      }
    } catch (e) {
      developer.log(
        'Error en AuthService.changePassword: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }

  // 🔑 Solicitar recuperación de contraseña
  static Future<String> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw Exception('El email no puede estar vacío');
      }

      final response = await ApiService.post(
        '/api/password-reset/',
        body: {'email': email},
        withAuth: false, // No requiere autenticación
      );

      developer.log(
        'resetPassword response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log(
        'resetPassword response body: ${response.body}',
        name: 'AuthService',
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['message'] ?? 'Correo enviado exitosamente';
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        String errorMessage =
            errorBody['error'] ?? 'Error al procesar la solicitud';
        throw Exception(errorMessage);
      } else if (response.statusCode == 403) {
        final errorBody = jsonDecode(response.body);
        String errorMessage = errorBody['error'] ?? 'Acceso denegado';
        throw Exception(errorMessage);
      } else if (response.statusCode == 500) {
        final errorBody = jsonDecode(response.body);
        String errorMessage = errorBody['error'] ?? 'Error del servidor';
        throw Exception(errorMessage);
      } else {
        throw Exception(
          'Error desconocido al solicitar recuperación de contraseña',
        );
      }
    } catch (e) {
      developer.log(
        'Error en AuthService.resetPassword: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }

  // 🔑 Confirmar recuperación de contraseña
  static Future<String> confirmResetPassword(
    String uid,
    String token,
    String newPassword,
  ) async {
    try {
      if (uid.isEmpty || token.isEmpty || newPassword.isEmpty) {
        throw Exception('Todos los campos son requeridos');
      }

      if (newPassword.length < 8) {
        throw Exception('La contraseña debe tener al menos 8 caracteres');
      }

      final response = await ApiService.post(
        '/password-reset-confirm/',
        body: {'uid': uid, 'token': token, 'new_password': newPassword},
        withAuth: false, // No requiere autenticación
      );

      developer.log(
        'confirmResetPassword response status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log(
        'confirmResetPassword response body: ${response.body}',
        name: 'AuthService',
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['message'] ?? 'Contraseña actualizada exitosamente';
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        String errorMessage =
            errorBody['error'] ?? 'Error al actualizar la contraseña';
        throw Exception(errorMessage);
      } else {
        throw Exception(
          'Error desconocido al confirmar recuperación de contraseña',
        );
      }
    } catch (e) {
      developer.log(
        'Error en AuthService.confirmResetPassword: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }
}
