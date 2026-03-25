// ----------------------------------------
// lib/services/cache_service.dart
// Servicio de caché local para la aplicación.
// ----------------------------------------
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  /// Inicializar el servicio de caché
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Guardar datos en caché
  Future<void> setCache(String key, dynamic value, {Duration? expiry}) async {
    if (!_isInitialized) await init();

    final cacheData = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inSeconds,
    };
    await _prefs.setString(key, jsonEncode(cacheData));
  }

  /// Obtener datos de caché
  dynamic getCache(String key) {
    if (!_isInitialized) return null;

    final cached = _prefs.getString(key);
    if (cached == null) return null;

    try {
      final data = jsonDecode(cached);
      final timestamp = data['timestamp'] as int;
      final expiry = data['expiry'] as int?;

      if (expiry != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > expiry * 1000) {
          _prefs.remove(key);
          return null;
        }
      }
      return data['value'];
    } catch (e) {
      return null;
    }
  }

  /// Eliminar un elemento del caché
  Future<void> clearCache(String key) async {
    if (!_isInitialized) await init();
    await _prefs.remove(key);
  }

  /// Eliminar todo el caché
  Future<void> clearAllCache() async {
    if (!_isInitialized) await init();
    await _prefs.clear();
  }

  /// Verificar si existe una clave en caché
  bool hasCache(String key) {
    if (!_isInitialized) return false;
    return _prefs.containsKey(key);
  }
}
