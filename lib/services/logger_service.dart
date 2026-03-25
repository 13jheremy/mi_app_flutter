// ----------------------------------------
// lib/services/logger_service.dart
// Servicio de logging estructurado para la aplicación.
// ----------------------------------------
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class LoggerService {
  /// Log de tipo información (nivel 800)
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'App', level: 800);
    }
  }

  /// Log de tipo advertencia (nivel 900)
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'App', level: 900);
    }
  }

  /// Log de tipo error (nivel 1000)
  static void error(String message, {String? tag, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'App',
        level: 1000,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log de tipo debug (nivel 500)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'App', level: 500);
    }
  }

  /// Log detallado para desarrollo
  static void verbose(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'App', level: 200);
    }
  }
}
