// lib/config/environments.dart
// Configuración de entornos para la aplicación

enum Environment { dev, staging, prod }

class AppConfig {
  static Environment current = Environment.dev;

  static String get apiUrl {
    switch (current) {
      case Environment.dev:
        return 'https://proyecto-2026-ts4b.onrender.com';
      case Environment.staging:
        return 'https://staging-proyecto-2026.onrender.com';
      case Environment.prod:
        return 'https://proyecto-2026-ts4b.onrender.com';
    }
  }

  static String get appName {
    switch (current) {
      case Environment.dev:
        return 'MotoApp Dev';
      case Environment.staging:
        return 'MotoApp Staging';
      case Environment.prod:
        return 'MotoApp';
    }
  }

  // Sentry DSN por ambiente
  static String get sentryDsn {
    switch (current) {
      case Environment.dev:
        return ''; // Opcional para desarrollo
      case Environment.staging:
        return 'https://examplePublicKey@o0.ingest.sentry.io/0'; // Reemplazar con tu DSN real
      case Environment.prod:
        return 'https://examplePublicKey@o0.ingest.sentry.io/0'; // Reemplazar con tu DSN real
    }
  }

  // Habilitar Sentry
  static bool get enableSentry {
    return sentryDsn.isNotEmpty;
  }

  static String get bundleId {
    switch (current) {
      case Environment.dev:
        return 'com.example.flutter_final.dev';
      case Environment.staging:
        return 'com.example.flutter_final.staging';
      case Environment.prod:
        return 'com.example.flutter_final';
    }
  }

  static bool get enableLogging {
    return current != Environment.prod;
  }

  // Habilitar crash reporting en producción y staging
  static bool get enableCrashReporting {
    return current == Environment.prod || current == Environment.staging;
  }
}
