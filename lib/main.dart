// ----------------------------------------
// lib/main.dart
// El punto de entrada de la aplicación.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'dart:ui' show PlatformDispatcher;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '/config/theme.dart';
import '/config/environments.dart';
import '/providers/auth_provider.dart';
import '/providers/data_provider.dart';
import '/providers/product_provider.dart';
import '/providers/category_provider.dart';
import '/screens/login_screen.dart';
import '/screens/dashboard_screen.dart';
import '/screens/forgot_password_screen.dart';
import '/screens/reset_password_screen.dart';
import '/services/notification_service.dart';
import '/services/theme_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar manejo de errores global
  FlutterError.onError = (errorDetails) {
    if (AppConfig.enableCrashReporting) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    }
  };

  // Capturar errores de zona
  PlatformDispatcher.instance.onError = (error, stack) {
    if (AppConfig.enableCrashReporting) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    AppConfig.enableCrashReporting,
  );

  // Inicializar Analytics
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Configurar manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar servicio de notificaciones
  await NotificationService().initialize();

  // Ejecutar la app con Sentry
  if (AppConfig.enableSentry) {
    await SentryFlutter.init((options) {
      options.dsn = AppConfig.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.environment = AppConfig.current.name;
      options.release = 'flutter_final@${AppConfig.current.name}';
    }, appRunner: () => runApp(const MyApp()));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final savedTheme = await ThemeService.getSavedThemeMode();
    setState(() {
      _themeMode = savedTheme;
    });
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    ThemeService.saveThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ), // Registrar CategoryProvider
        Provider<ThemeModeChanger>(
          create: (_) => ThemeModeChanger(changeTheme),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationService
            .navigatorKey, // Clave de navegación para notificaciones
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/reset-password') {
            final args = settings.arguments as Map<String, String>?;
            return MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordScreen(uid: args?['uid'], token: args?['token']),
            );
          }
          return null;
        },
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const SplashScreen();
            }
            if (authProvider.isAuthenticated) {
              return const DashboardScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

class ThemeModeChanger {
  final void Function(ThemeMode) changeTheme;
  ThemeModeChanger(this.changeTheme);
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode
                  ? const Color(0xFF1e293b)
                  : const Color(0xFF7f1d1d), // slate-800 : red-900
              isDarkMode
                  ? const Color(0xFF7f1d1d)
                  : const Color(0xFFdc2626), // red-900 : red-600
              isDarkMode
                  ? const Color(0xFFdc2626)
                  : const Color(0xFFb91c1c), // red-600 : red-700
              isDarkMode
                  ? const Color(0xFFb91c1c)
                  : const Color(0xFF1e293b), // red-700 : slate-800
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'JIC',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626), // red-600
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Welcome text
              Text(
                'Bienvenido a JIC',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Taller y Repuestos',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
