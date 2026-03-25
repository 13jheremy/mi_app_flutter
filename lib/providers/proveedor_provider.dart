// ----------------------------------------
// lib/providers/proveedor_provider.dart
// Proveedor para la gestión de proveedores.
// ----------------------------------------
import 'dart:convert' show jsonDecode;
import 'package:flutter/foundation.dart';
import '../models/proveedor.dart';
import '../services/api_service.dart';

class ProveedorProvider extends ChangeNotifier {
  List<Proveedor> _proveedores = [];
  List<Proveedor> _filteredProveedores = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Proveedor> get proveedores => _filteredProveedores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Cargar todos los proveedores
  Future<void> fetchProveedores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/api/proveedores/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body.isNotEmpty
            ? _parseJson(response.body)
            : [];
        _proveedores = data.map((json) => Proveedor.fromJson(json)).toList();
        _applyFilters();
      } else {
        _errorMessage = 'Error al cargar proveedores: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Parsear JSON de forma segura
  List<dynamic> _parseJson(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded.containsKey('results')) {
        return decoded['results'] as List;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Buscar proveedores
  void searchProveedores(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Aplicar filtros de búsqueda
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredProveedores = List.from(_proveedores);
    } else {
      _filteredProveedores = _proveedores.where((proveedor) {
        final queryLower = _searchQuery.toLowerCase();
        return proveedor.nombre.toLowerCase().contains(queryLower) ||
            (proveedor.nit?.toLowerCase().contains(queryLower) ?? false) ||
            (proveedor.correo?.toLowerCase().contains(queryLower) ?? false) ||
            (proveedor.telefono?.contains(queryLower) ?? false);
      }).toList();
    }
  }

  /// Obtener un proveedor por ID
  Proveedor? getProveedorById(int id) {
    try {
      return _proveedores.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Crear un nuevo proveedor
  Future<bool> createProveedor(Map<String, dynamic> proveedorData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/proveedores/',
        body: proveedorData,
      );

      if (response.statusCode == 201) {
        final newProveedor = Proveedor.fromJson(jsonDecode(response.body));
        _proveedores.add(newProveedor);
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al crear proveedor: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualizar un proveedor
  Future<bool> updateProveedor(
    int id,
    Map<String, dynamic> proveedorData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.patch(
        '/api/proveedores/$id/',
        body: proveedorData,
      );

      if (response.statusCode == 200) {
        final updatedProveedor = Proveedor.fromJson(jsonDecode(response.body));
        final index = _proveedores.indexWhere((p) => p.id == id);
        if (index != -1) {
          _proveedores[index] = updatedProveedor;
          _applyFilters();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al actualizar proveedor: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Eliminar (soft delete) un proveedor
  Future<bool> deleteProveedor(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.patch(
        '/api/proveedores/$id/soft_delete/',
        body: {},
      );

      if (response.statusCode == 200) {
        final index = _proveedores.indexWhere((p) => p.id == id);
        if (index != -1) {
          final proveedor = _proveedores[index];
          _proveedores[index] = Proveedor(
            id: proveedor.id,
            nombre: proveedor.nombre,
            nit: proveedor.nit,
            telefono: proveedor.telefono,
            correo: proveedor.correo,
            direccion: proveedor.direccion,
            contactoPrincipal: proveedor.contactoPrincipal,
            activo: proveedor.activo,
            eliminado: true,
            productosCount: proveedor.productosCount,
            fechaRegistro: proveedor.fechaRegistro,
            fechaActualizacion: proveedor.fechaActualizacion,
            fechaEliminacion: DateTime.now(),
            creadoPor: proveedor.creadoPor,
            actualizadoPor: proveedor.actualizadoPor,
            eliminadoPor: proveedor.eliminadoPor,
          );
          _applyFilters();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al eliminar proveedor: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restaurar un proveedor eliminado
  Future<bool> restoreProveedor(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.patch(
        '/api/proveedores/$id/restore/',
        body: {},
      );

      if (response.statusCode == 200) {
        final restoredProveedor = Proveedor.fromJson(jsonDecode(response.body));
        final index = _proveedores.indexWhere((p) => p.id == id);
        if (index != -1) {
          _proveedores[index] = restoredProveedor;
          _applyFilters();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al restaurar proveedor: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
