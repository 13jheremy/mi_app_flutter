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
    _isLoadingData = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cargar datos usando los endpoints específicos para cliente
      developer.log('Starting data fetch...', name: 'DataProvider');

      // Limpiar datos anteriores para evitar mostrar datos antiguos con valores nulos
      _reminders = [];
      _maintenances = [];
      _motorcycles = [];
      _sales = [];

      // Primero cargar las motos del cliente
      _motorcycles = await DataService.fetchMotorcycles();
      developer.log(
        'Motorcycles loaded: ${_motorcycles.length}',
        name: 'DataProvider',
      );

      // Cargar todos los mantenimientos del cliente (no por moto individual)
      // El endpoint ya filtra por el propietario
      try {
        _maintenances = await DataService.fetchMaintenances(
          0,
        ); // 0 = todos los mantenimientos
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
      // Si hay error, dejar listas vacías para evitar crashes
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
