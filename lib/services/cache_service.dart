// ----------------------------------------
// lib/services/cache_service.dart
// Servicio de caché local usando SQLite para persistencia de datos
// Soporta TTL y sincronización offline
// ----------------------------------------
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

class CacheService {
  static final CacheService _instance = CacheService._internal();
  static Database? _database;

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'moto_app_cache.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
      );
    } catch (e) {
      developer.log('Error initializing database: $e', name: 'CacheService');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    try {
      // Tabla para cache genérico
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT UNIQUE NOT NULL,
          value TEXT NOT NULL,
          expiresAt INTEGER NOT NULL
        )
      ''');

      // Tabla para motos del cliente
      await db.execute('''
        CREATE TABLE IF NOT EXISTS motorcycles (
          id INTEGER PRIMARY KEY,
          data TEXT NOT NULL,
          cachedAt INTEGER NOT NULL
        )
      ''');

      // Tabla para mantenimientos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS maintenances (
          id INTEGER PRIMARY KEY,
          data TEXT NOT NULL,
          cachedAt INTEGER NOT NULL
        )
      ''');

      // Tabla para productos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY,
          data TEXT NOT NULL,
          cachedAt INTEGER NOT NULL
        )
      ''');

      // Tabla para categorías
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY,
          data TEXT NOT NULL,
          cachedAt INTEGER NOT NULL
        )
      ''');

      developer.log('✓ Database tables created', name: 'CacheService');
    } catch (e) {
      developer.log('Error creating tables: $e', name: 'CacheService');
      rethrow;
    }
  }

  // Guardar valor en caché genérico
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    try {
      final db = await database;
      final expiresAt = DateTime.now()
          .add(ttl ?? const Duration(hours: 24))
          .millisecondsSinceEpoch;

      await db.insert(
        'cache',
        {
          'key': key,
          'value': jsonEncode(value),
          'expiresAt': expiresAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      developer.log('✓ Cached: $key (TTL: ${ttl?.inMinutes ?? 1440} min)',
          name: 'CacheService');
    } catch (e) {
      developer.log('Error caching data: $e', name: 'CacheService');
    }
  }

  // Obtener valor del caché genérico
  Future<dynamic> get(String key) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final result = await db.query(
        'cache',
        where: 'key = ? AND expiresAt > ?',
        whereArgs: [key, now],
      );

      if (result.isNotEmpty) {
        developer.log('✓ Cache hit: $key', name: 'CacheService');
        return jsonDecode(result.first['value'] as String);
      }

      developer.log('✗ Cache miss: $key', name: 'CacheService');
      return null;
    } catch (e) {
      developer.log('Error retrieving cache: $e', name: 'CacheService');
      return null;
    }
  }

  // Borrar entrada de caché
  Future<void> delete(String key) async {
    try {
      final db = await database;
      await db.delete('cache', where: 'key = ?', whereArgs: [key]);
      developer.log('✓ Cache deleted: $key', name: 'CacheService');
    } catch (e) {
      developer.log('Error deleting cache: $e', name: 'CacheService');
    }
  }

  // Borrar todo el caché
  Future<void> clear() async {
    try {
      final db = await database;
      await db.delete('cache');
      developer.log('✓ Cache cleared', name: 'CacheService');
    } catch (e) {
      developer.log('Error clearing cache: $e', name: 'CacheService');
    }
  }

  // Borrar caché expirado
  Future<void> clearExpired() async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final deleted = await db.delete(
        'cache',
        where: 'expiresAt <= ?',
        whereArgs: [now],
      );

      developer.log('✓ Expired cache cleared ($deleted entries)',
          name: 'CacheService');
    } catch (e) {
      developer.log('Error clearing expired cache: $e', name: 'CacheService');
    }
  }

  // Métodos específicos para tablas
  Future<void> cacheMotorcycles(List<Map<String, dynamic>> motorcycles) async {
    try {
      final db = await database;
      await db.delete('motorcycles');

      for (final moto in motorcycles) {
        await db.insert(
          'motorcycles',
          {
            'id': moto['id'],
            'data': jsonEncode(moto),
            'cachedAt': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      developer.log('✓ Motorcycles cached (${motorcycles.length} items)',
          name: 'CacheService');
    } catch (e) {
      developer.log('Error caching motorcycles: $e', name: 'CacheService');
    }
  }

  Future<List<Map<String, dynamic>>> getMotorcycles() async {
    try {
      final db = await database;
      final result = await db.query('motorcycles');

      if (result.isEmpty) {
        developer.log('✗ No cached motorcycles', name: 'CacheService');
        return [];
      }

      developer.log('✓ Retrieved ${result.length} cached motorcycles',
          name: 'CacheService');
      return result
          .map((row) => jsonDecode(row['data'] as String) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      developer.log('Error retrieving motorcycles: $e', name: 'CacheService');
      return [];
    }
  }

  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    try {
      final db = await database;
      await db.delete('products');

      for (final product in products) {
        await db.insert(
          'products',
          {
            'id': product['id'],
            'data': jsonEncode(product),
            'cachedAt': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      developer.log('✓ Products cached (${products.length} items)',
          name: 'CacheService');
    } catch (e) {
      developer.log('Error caching products: $e', name: 'CacheService');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final db = await database;
      final result = await db.query('products');

      if (result.isEmpty) return [];

      return result
          .map((row) => jsonDecode(row['data'] as String) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      developer.log('Error retrieving products: $e', name: 'CacheService');
      return [];
    }
  }

  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    try {
      final db = await database;
      await db.delete('categories');

      for (final category in categories) {
        await db.insert(
          'categories',
          {
            'id': category['id'],
            'data': jsonEncode(category),
            'cachedAt': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      developer.log('✓ Categories cached (${categories.length} items)',
          name: 'CacheService');
    } catch (e) {
      developer.log('Error caching categories: $e', name: 'CacheService');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final db = await database;
      final result = await db.query('categories');

      if (result.isEmpty) return [];

      return result
          .map((row) => jsonDecode(row['data'] as String) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      developer.log('Error retrieving categories: $e', name: 'CacheService');
      return [];
    }
  }

  // Obtener estado del caché
  Future<String> getCacheStats() async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cache')) ??
        0;
      final motos = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM motorcycles')) ??
        0;
      final products = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products')) ??
        0;
      final categories = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM categories')) ??
        0;

      return 'Cache: $count keys, $motos motos, $products products, $categories categories';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
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
