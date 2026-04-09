// ----------------------------------------
// lib/providers/data_provider.dart
// Provedor para la gestión de los datos del cliente.
// ----------------------------------------
import 'package:flutter/material.dart';
import '/models/motorcycle.dart';
import '/models/maintenance.dart';
import '/models/reminder.dart';
import '/models/sale.dart';
import '/services/data_service.dart';
import 'dart:developer' as developer;

class DataProvider extends ChangeNotifier {
  List<Motorcycle> _motorcycles = [];
  List<Maintenance> _maintenances = [];
  List<Reminder> _reminders = [];
  List<Sale> _sales = [];
  bool _isLoadingData = false;
  String? _errorMessage;

  List<Motorcycle> get motorcycles => _motorcycles;
  List<Maintenance> get maintenances => _maintenances;
  List<Reminder> get reminders => _reminders;
  List<Sale> get sales => _sales;
  bool get isLoadingData => _isLoadingData;
  String? get errorMessage => _errorMessage;

  // Método para obtener todos los datos del cliente
  Future<void> fetchData() async {
    print('=== DataProvider.fetchData INICIADO ===');
    _isLoadingData = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Starting data fetch...');

      // Limpiar datos anteriores
      _reminders = [];
      _maintenances = [];
      _motorcycles = [];
      _sales = [];
      notifyListeners();

      // Cargar las motos del cliente
      print('Antes de llamar a DataService.fetchMotorcycles');
      _motorcycles = await DataService.fetchMotorcycles();
      print('Despues de fetchMotorcycles - count: ${_motorcycles.length}');
      if (_motorcycles.isNotEmpty) {
        print(
          'Primera moto: ${_motorcycles[0].marca} ${_motorcycles[0].modelo}',
        );
      }
      notifyListeners();

      // Cargar mantenimientos
      try {
        _maintenances = await DataService.fetchMaintenances(0);
        developer.log(
          'Maintenances loaded: ${_maintenances.length}',
          name: 'DataProvider',
        );
      } catch (e) {
        developer.log('Error loading maintenances: $e', name: 'DataProvider');
        _maintenances = [];
      }

      // Cargar recordatorios
      try {
        _reminders = await DataService.fetchReminders();
        developer.log(
          'Reminders loaded: ${_reminders.length}',
          name: 'DataProvider',
        );
      } catch (e) {
        developer.log('Error loading reminders: $e', name: 'DataProvider');
        _reminders = [];
      }

      // Cargar ventas del cliente
      try {
        _sales = await DataService.fetchSales();
        developer.log('Sales loaded: ${_sales.length}', name: 'DataProvider');
      } catch (e) {
        developer.log('Error loading sales: $e', name: 'DataProvider');
        _sales = [];
      }

      developer.log('All data loaded successfully!', name: 'DataProvider');
    } catch (e) {
      _errorMessage = 'Error al cargar los datos: $e';
      developer.log('Error in fetchData: $_errorMessage', name: 'DataProvider');
      _motorcycles = [];
      _maintenances = [];
      _reminders = [];
      _sales = [];
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  // Método para recargar mantenimientos de una moto específica
  Future<List<Maintenance>> fetchMaintenancesForMotorcycle(
    int motorcycleId,
  ) async {
    try {
      developer.log(
        'Fetching maintenances for motorcycle: $motorcycleId',
        name: 'DataProvider',
      );
      final motoMaintenances = await DataService.fetchMaintenances(
        motorcycleId,
      );
      developer.log(
        'Found ${motoMaintenances.length} maintenances for motorcycle $motorcycleId',
        name: 'DataProvider',
      );
      return motoMaintenances;
    } catch (e) {
      developer.log(
        'Error fetching maintenances for motorcycle $motorcycleId: $e',
        name: 'DataProvider',
      );
      return [];
    }
  }

  // Método para obtener los mantenimientos de cambio de aceite.
  List<Maintenance> get oilChangeMaintenances {
    return _maintenances
        .where(
          (m) =>
              m.service.categoriaNombre.toLowerCase().contains('aceite') ||
              m.service.categoriaNombre.toLowerCase().contains('filtro'),
        )
        .toList();
  }

  // Obtener mantenimientos por estado
  List<Maintenance> getMaintenancesByState(String estado) {
    return _maintenances
        .where((m) => m.estado.toLowerCase() == estado.toLowerCase())
        .toList();
  }

  // Obtener el resumen de mantenimientos
  Map<String, int> get mantenimientosResumen {
    return {
      'total': _maintenances.length,
      'pendientes': _maintenances.where((m) => m.estado == 'pendiente').length,
      'en_proceso': _maintenances.where((m) => m.estado == 'en_proceso').length,
      'completados': _maintenances
          .where((m) => m.estado == 'completado')
          .length,
    };
  }
}
