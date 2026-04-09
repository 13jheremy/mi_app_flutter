// lib/providers/category_provider.dart
import 'package:flutter/material.dart';
import '/models/category.dart';
import '/services/data_service.dart';
import 'dart:developer' as developer;

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      developer.log(
        'Iniciando carga de categorías...',
        name: 'CategoryProvider',
      );
      _categories = await DataService.fetchCategories();
      developer.log(
        'Categorías cargadas exitosamente: ${_categories.length}',
        name: 'CategoryProvider',
      );
      developer.log(
        'Categorías: ${_categories.map((c) => c.nombre).toList()}',
        name: 'CategoryProvider',
      );
    } catch (e) {
      _errorMessage = e.toString();
      developer.log(
        'Error en fetchCategories: $_errorMessage',
        name: 'CategoryProvider',
        level: 1000,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
