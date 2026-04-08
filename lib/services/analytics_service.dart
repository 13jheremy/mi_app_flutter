// lib/services/analytics_service.dart
// Servicio para Firebase Analytics

import 'package:firebase_analytics/firebase_analytics.dart';
import '/config/environments.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  late final FirebaseAnalytics _analytics;

  AnalyticsService._internal() {
    _analytics = FirebaseAnalytics.instance;
  }

  // Tracking de pantallas
  Future<void> trackScreen(String screenName, {String? screenClass}) async {
    if (!AppConfig.enableLogging) return;

    await _analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClass,
    );
  }

  // Tracking de eventos personalizados
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!AppConfig.enableLogging) return;

    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // Tracking de login
  Future<void> trackLogin(String method) async {
    await trackEvent('login', parameters: {'method': method});
  }

  // Tracking de logout
  Future<void> trackLogout() async {
    await trackEvent('logout');
  }

  // Tracking de errores
  Future<void> trackError(String error, {String? stackTrace}) async {
    await trackEvent('error', parameters: {
      'error': error,
      'stack_trace': stackTrace,
    });
  }

  // Tracking de acciones CRUD
  Future<void> trackCrudAction(String action, String entity, {String? entityId}) async {
    await trackEvent('crud_action', parameters: {
      'action': action, // create, read, update, delete
      'entity': entity, // product, motorcycle, etc.
      'entity_id': entityId,
    });
  }

  // Tracking de búsqueda
  Future<void> trackSearch(String searchTerm, String category) async {
    await trackEvent('search', parameters: {
      'search_term': searchTerm,
      'category': category,
    });
  }

  // Tracking de compras/carrito
  Future<void> trackPurchase(String itemId, double price, String currency) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [AnalyticsEventItem(itemId: itemId, price: price)],
    );
  }

  // Tracking de tiempo de sesión
  Future<void> trackSessionStart() async {
    await trackEvent('session_start');
  }

  Future<void> trackSessionEnd() async {
    await trackEvent('session_end');
  }

  // Configurar propiedades de usuario
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Configurar ID de usuario
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}