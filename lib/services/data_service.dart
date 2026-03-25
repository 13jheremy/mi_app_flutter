// ----------------------------------------
// lib/services/data_service.dart
// Lógica para obtener todos los datos del cliente (versión segura).
// ----------------------------------------
import 'dart:convert';
import 'dart:developer' as developer; // Importa el paquete para logging

import '/models/motorcycle.dart';
import '/models/maintenance.dart';
import '/models/reminder.dart';
import '/models/sale.dart';
import '/models/product.dart'; // Importar el nuevo modelo Product
import '/services/api_service.dart';
import '/models/category.dart';

class DataService {
  // Método seguro para obtener una lista desde JSON
  static List<dynamic> _extractList(dynamic jsonData, String key) {
    if (jsonData is List) {
      return jsonData;
    } else if (jsonData is Map &&
        jsonData.containsKey(key) &&
        jsonData[key] is List) {
      return jsonData[key];
    } else {
      return []; // Devuelve lista vacía si no existe
    }
  }

  static Future<List<Motorcycle>> fetchMotorcycles() async {
    developer.log(
      'Fetching motorcycles from /api/cliente/motos/',
      name: 'DataService',
    );
    final response = await ApiService.get('/api/cliente/motos/');
    developer.log(
      'Response status: ${response.statusCode}',
      name: 'DataService',
    );
    developer.log('Response body: ${response.body}', name: 'DataService');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      developer.log('Parsed data: $data', name: 'DataService');
      // El endpoint de cliente devuelve {success: true, data: [...], count: N}
      if (data['success'] == true) {
        final motorcyclesJson = _extractList(data['data'] ?? [], '');
        developer.log(
          'Motorcycles JSON count: ${motorcyclesJson.length}',
          name: 'DataService',
        );
        developer.log(
          'Motorcycles JSON first: ${motorcyclesJson.isNotEmpty ? motorcyclesJson[0] : "empty"}',
          name: 'DataService',
        );
        try {
          final result = motorcyclesJson
              .map((m) => Motorcycle.fromJson(m))
              .toList();
          developer.log(
            'Parsed motorcycles count: ${result.length}',
            name: 'DataService',
          );
          return result;
        } catch (e, stackTrace) {
          developer.log('Error parsing motorcycles: $e', name: 'DataService');
          developer.log('Stack trace: $stackTrace', name: 'DataService');
          return [];
        }
      } else {
        developer.log(
          'Respuesta inesperada del endpoint cliente/motos: $data',
          name: 'DataService',
        );
        return [];
      }
    } else {
      throw Exception(
        'Error al cargar las motos: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<List<Maintenance>> fetchMaintenances(int motorcycleId) async {
    // El endpoint /api/cliente/mantenimientos/ ya devuelve todos los mantenimientos
    // del cliente autenticado. No acepta parámetros de filtro.
    developer.log(
      'Fetching all client maintenances from /api/cliente/mantenimientos/',
      name: 'DataService',
    );
    final response = await ApiService.get('/api/cliente/mantenimientos/');

    developer.log(
      'Response status: ${response.statusCode}',
      name: 'DataService',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // El endpoint de cliente devuelve {success: true, data: [...], count: N}
      if (data['success'] == true) {
        final maintenancesJson = _extractList(data['data'] ?? [], '');
        developer.log(
          'Total maintenances from API: ${maintenancesJson.length}',
          name: 'DataService',
        );

        try {
          // Convertir a objetos Maintenance
          final allMaintenances = maintenancesJson
              .map((m) => Maintenance.fromJson(m as Map<String, dynamic>))
              .toList();

          // Si se especificó una moto específica, filtrar localmente
          if (motorcycleId != null && motorcycleId > 0) {
            final filtered = allMaintenances
                .where((m) => m.motoId == motorcycleId)
                .toList();
            developer.log(
              'Filtered ${filtered.length} maintenances for moto $motorcycleId',
              name: 'DataService',
            );
            return filtered;
          }

          developer.log(
            'Returning all ${allMaintenances.length} maintenances',
            name: 'DataService',
          );
          return allMaintenances;
        } catch (e, stackTrace) {
          developer.log('Error parsing maintenances: $e', name: 'DataService');
          developer.log('Stack trace: $stackTrace', name: 'DataService');
          return [];
        }
      } else {
        developer.log(
          'Respuesta inesperada del endpoint cliente/mantenimientos: $data',
          name: 'DataService',
        );
        return [];
      }
    } else {
      throw Exception(
        'Error al cargar los mantenimientos: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<List<Reminder>> fetchReminders() async {
    developer.log('Fetching reminders...', name: 'DataService');

    // Intentar primero con el endpoint proximos
    try {
      final response = await ApiService.get(
        'api/recordatorios-mantenimiento/proximos/?dias=60&limite=100',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Reminders response: $data', name: 'DataService');

        final recordatorios = data['recordatorios'] as List? ?? [];
        developer.log(
          'Found ${recordatorios.length} reminders from proximos',
          name: 'DataService',
        );

        if (recordatorios.isNotEmpty) {
          return recordatorios
              .map((r) => Reminder.fromJson(r as Map<String, dynamic>))
              .toList();
        }
      } else {
        developer.log(
          'Error fetching reminders: ${response.statusCode}',
          name: 'DataService',
        );
      }
    } catch (e) {
      developer.log('Exception fetching proximos: $e', name: 'DataService');
    }

    // Fallback: usar el endpoint de lista
    try {
      final listResponse = await ApiService.get(
        'api/recordatorios-mantenimiento/',
      );

      if (listResponse.statusCode == 200) {
        final data = json.decode(listResponse.body);
        developer.log('Reminders list keys: ${data.keys}', name: 'DataService');

        // El endpoint devuelve {count, next, previous, results: [...]}
        final results = data['results'];
        if (results is List) {
          developer.log(
            'Found ${results.length} from list',
            name: 'DataService',
          );
          return results
              .map((r) => Reminder.fromJson(r as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
    } catch (e) {
      developer.log('Exception list: $e', name: 'DataService');
    }

    return [];
  }

  static Future<List<Sale>> fetchSales() async {
    final response = await ApiService.get('api/cliente/ventas/');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // El endpoint de cliente devuelve {success: true, data: [...], count: N}
      if (data['success'] == true) {
        final salesJson = _extractList(data['data'] ?? [], '');
        try {
          return salesJson.map((s) => Sale.fromJson(s)).toList();
        } catch (e) {
          developer.log('Error parsing sales: $e', name: 'DataService');
          return [];
        }
      } else {
        developer.log(
          'Respuesta inesperada del endpoint cliente/ventas: $data',
          name: 'DataService',
        );
        return [];
      }
    } else {
      throw Exception(
        'Error al cargar las ventas: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Nuevo método para obtener productos del catálogo
  static Future<List<Product>> fetchProducts() async {
    // Usar el endpoint público si es posible, o el autenticado si se necesita más detalle
    final response = await ApiService.get(
      '/api/publico/productos/',
    ); // O '/productos/' si se requiere autenticación
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final productsJson = _extractList(
        data,
        'results',
      ); // Asume que devuelve una lista directa
      try {
        return productsJson.map((p) => Product.fromJson(p)).toList();
      } catch (e) {
        developer.log('Error parsing products: $e', name: 'DataService');
        return [];
      }
    } else {
      throw Exception(
        'Error al cargar productos: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<List<Category>> fetchCategories() async {
    final response = await ApiService.get('/api/publico/categorias/');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // CORRECTED: Use 'results' as the key to extract the list
      final categoriesJson = _extractList(data, 'results');
      try {
        return categoriesJson.map((c) => Category.fromJson(c)).toList();
      } catch (e) {
        developer.log('Error parsing categories: $e', name: 'DataService');
        return [];
      }
    } else {
      throw Exception(
        'Error al cargar categorías: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Método para actualizar el perfil del usuario
  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await ApiService.patch('/api/me/', body: userData);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('[DataService] Error actualizando perfil: $e');
      throw Exception('No se pudo actualizar el perfil');
    }
  }

  // Método para actualizar token FCM
  static Future<bool> updateFCMToken(String token) async {
    try {
      developer.log('╔══════════════════════════════════════════════════╗');
      developer.log('║ [DataService] ENVIANDO TOKEN FCM AL BACKEND     ║');
      developer.log('╚══════════════════════════════════════════════════╝');
      developer.log('[DataService] Token FCM a enviar: $token');
      developer.log('[DataService] Endpoint: PATCH /api/me/');
      developer.log('[DataService] Body: {"fcm_token": "$token"}');

      final response = await ApiService.patch(
        '/api/me/',
        body: {'fcm_token': token},
      );

      developer.log('[DataService] Respuesta recibida:');
      developer.log('[DataService] Status Code: ${response.statusCode}');
      developer.log('[DataService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        developer.log('╔══════════════════════════════════════════════════╗');
        developer.log('║ ✅ [DataService] TOKEN FCM ACTUALIZADO           ║');
        developer.log('╚══════════════════════════════════════════════════╝');
        return true;
      } else {
        developer.log('╔══════════════════════════════════════════════════╗');
        developer.log('║ ❌ [DataService] ERROR ACTUALIZANDO TOKEN FCM   ║');
        developer.log('╚══════════════════════════════════════════════════╝');
        developer.log('[DataService] Código de error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('╔══════════════════════════════════════════════════╗');
      developer.log('║ ❌ [DataService] EXCEPCIÓN ENVIANDO TOKEN FCM    ║');
      developer.log('╚══════════════════════════════════════════════════╝');
      developer.log('[DataService] Error: $e');
      developer.log('[DataService] Tipo de error: ${e.runtimeType}');
      return false;
    }
  }
}
