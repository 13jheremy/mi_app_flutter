// ----------------------------------------
// lib/providers/product_provider.dart
// Proveedor para la gestión de datos del catálogo de productos.
// ----------------------------------------
import 'package:flutter/material.dart';
import '/models/product.dart'; // Necesitarás crear este modelo
import '/services/data_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentSearchQuery = '';
  String? _currentCategoryFilter;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await DataService.fetchProducts();
      _applyFilters(); // Aplicar filtros existentes después de cargar
    } catch (e) {
      _errorMessage = 'Error al cargar productos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _currentSearchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterProductsByCategory(String? categoryId) {
    _currentCategoryFilter = categoryId;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch =
          _currentSearchQuery.isEmpty ||
          product.nombre.toLowerCase().contains(_currentSearchQuery) ||
          product.codigo.toLowerCase().contains(_currentSearchQuery);

      final matchesCategory =
          _currentCategoryFilter == null ||
          product.categoriaId.toString() ==
              _currentCategoryFilter; // Asume categoryId es int

      return matchesSearch && matchesCategory;
    }).toList();
    notifyListeners();
  }
}
