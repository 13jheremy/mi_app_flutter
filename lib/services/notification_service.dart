import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/services/data_service.dart';
import '/screens/maintenance_screen.dart';
import '/screens/motorcycles_screen.dart';
import '/screens/reminders_screen.dart';
import '/screens/sales_screen.dart';
import '/screens/product_catalog_screen.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Global navigator key para navegación desde notificaciones
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    try {
      // Verificar si Firebase está disponible (en caso de que no esté configurado)
      if (!kIsWeb) {
        try {
          // Inicializar Firebase
          await Firebase.initializeApp();

          // Inicializar FirebaseMessaging después de Firebase.initializeApp()
          _firebaseMessaging = FirebaseMessaging.instance;

          // Configurar notificaciones locales
          await _initializeLocalNotifications();

          // Configurar Firebase Messaging
          await _initializeFirebaseMessaging();

          // Obtener token FCM
          await _getFCMToken();

          // Configurar listeners
          _setupMessageHandlers();

          if (kDebugMode) {
            debugPrint('NotificationService inicializado correctamente');
          }
        } catch (firebaseError) {
          if (kDebugMode) {
            debugPrint('Firebase no disponible: $firebaseError');
            debugPrint('Las notificacionespush estarán deshabilitadas');
          }
          // Firebase no está configurado, continuar sin notificaciones push
          await _initializeLocalNotifications();
        }
      } else {
        // Web: solo notificaciones locales
        await _initializeLocalNotifications();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error general inicializando NotificationService: $e');
      }
    }
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificación para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificaciones Importantes',
      description: 'Canal para notificaciones importantes del taller',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Inicializar Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    if (_firebaseMessaging == null) return;

    // Solicitar permisos
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('Permisos de notificación: ${settings.authorizationStatus}');
    }

    // Configurar opciones para iOS
    await _firebaseMessaging!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Obtener token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging!.getToken();
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }

      // Enviar token al backend inmediatamente después de obtenerlo
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        if (kDebugMode) {
          print('Enviando token FCM inicial al backend...');
        }
        await _sendTokenToBackend(_fcmToken!);
      }

      // ==============================================
      // 1. MANEJO DE TOKEN REFRESCO (CRÍTICO)
      // El token puede cambiar, debemos reenviar al backend
      // ==============================================
      _firebaseMessaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('═══════════════════════════════════════════════════');
          print('🔄 FCM TOKEN ACTUALIZADO - Reenviando al backend');
          print('═══════════════════════════════════════════════════');
          print('Nuevo token: $newToken');
        }
        // Reenviar token actualizado al backend
        _sendTokenToBackend(newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo FCM token: $e');
      }
    }
  }

  /// Configurar manejadores de mensajes
  void _setupMessageHandlers() {
    if (_firebaseMessaging == null) {
      if (kDebugMode) {
        debugPrint(
          'FirebaseMessaging no disponible, omitiendo configuración de handlers',
        );
      }
      return;
    }

    // Mensaje recibido cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensaje tocado cuando la app está en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Verificar si la app se abrió desde una notificación
    _checkInitialMessage();
  }

  /// Manejar mensaje en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('📱 NOTIFICACIÓN RECIBIDA EN FOREGROUND');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('Message ID: ${message.messageId}');
      debugPrint('Título: ${message.notification?.title}');
      debugPrint('Cuerpo: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
    }

    // ==============================================
    // 2. MANEJO DE NOTIFICACIONES EN FOREGROUND
    // Si la app está abierta, mostrar feedback visual
    // ==============================================

    // Mostrar notificación local (esto funciona cuando la app está abierta)
    await _showLocalNotification(message);

    // También puedes mostrar un Snackbar o diálogo para mayor interactividad
    // Por ejemplo, navegar directamente a la pantalla relevante
    _handleNotificationAction(message.data);
  }

  /// Manejar tap en notificación de segundo plano
  void _handleBackgroundMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        'Notificación tocada desde segundo plano: ${message.messageId}',
      );
    }
    _handleNotificationAction(message.data);
  }

  /// Verificar mensaje inicial
  Future<void> _checkInitialMessage() async {
    if (_firebaseMessaging == null) return;

    RemoteMessage? initialMessage;
    try {
      initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error obteniendo mensaje inicial: $e');
      }
      return;
    }

    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint(
          'App abierta desde notificación: ${initialMessage.messageId}',
        );
      }
      _handleNotificationAction(initialMessage.data);
    }
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'Notificaciones Importantes',
          channelDescription:
              'Canal para notificaciones importantes del taller',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Taller de Motos',
      message.notification?.body ?? 'Nueva notificación',
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// Manejar tap en notificación local
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationAction(data);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error procesando payload de notificación: $e');
        }
      }
    }
  }

  /// Manejar acciones de notificación
  void _handleNotificationAction(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Procesando acción de notificación: $data');
    }

    // Navegación basada en el tipo de notificación
    final String? type = data['type'];
    // La variable 'action' no se usa actualmente

    switch (type) {
      case 'maintenance':
        // Navegar a pantalla de mantenimientos
        _navigateToMaintenance(null);
        break;
      case 'oil_change':
        // Navegar a pantalla de motos (para cambio de aceite)
        _navigateToMotorcycles();
        break;
      case 'appointment':
        // Navegar a recordatorios/citas
        _navigateToReminders();
        break;
      case 'promotion':
        // Navegar a catálogo de productos
        _navigateToProducts();
        break;
      case 'admin_summary':
        // Para administradores - navegar a ventas
        _navigateToSales();
        break;
      default:
        // Acción por defecto - ir al home
        _navigateToHome();
    }
  }

  /// Enviar token al backend
  Future<void> _sendTokenToBackend(String token) async {
    if (kDebugMode) {
      debugPrint('=== INICIANDO ENVÍO DE TOKEN FCM AL BACKEND ===');
      debugPrint('Token: $token');
    }

    try {
      // Importar DataService para enviar el token
      final success = await DataService.updateFCMToken(token);
      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Token FCM enviado exitosamente al backend');
          debugPrint('Token: $token');
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '❌ Error enviando token FCM al backend - El servicio devolvió false',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error enviando token al backend: $e');
        debugPrint('Tipo de error: ${e.runtimeType}');
      }
    }
  }

  /// Métodos de navegación implementados
  void _navigateToMaintenance(String? id) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
      );
      if (kDebugMode) {
        print('Navegando a pantalla de mantenimientos desde notificación');
      }
    }
  }

  void _navigateToMotorcycles() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MotorcyclesScreen()),
      );
      if (kDebugMode) {
        print('Navegando a pantalla de motos desde notificación');
      }
    }
  }

  void _navigateToReminders() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const RemindersScreen()));
      if (kDebugMode) {
        print('Navegando a pantalla de recordatorios desde notificación');
      }
    }
  }

  void _navigateToSales() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SalesScreen()));
      if (kDebugMode) {
        print('Navegando a pantalla de ventas desde notificación');
      }
    }
  }

  void _navigateToProducts() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProductCatalogScreen()),
      );
      if (kDebugMode) {
        print('Navegando a catálogo de productos desde notificación');
      }
    }
  }

  void _navigateToHome() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Si hay rutas en el stack, volver al inicio
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (kDebugMode) {
        print('Navegando a pantalla principal desde notificación');
      }
    }
  }

  /// Suscribirse a un tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging!.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Suscrito al tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error suscribiéndose al tópico $topic: $e');
      }
    }
  }

  /// Desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging!.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Desuscrito del tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error desuscribiéndose del tópico $topic: $e');
      }
    }
  }

  /// Limpiar recursos
  void dispose() {
    // Limpiar listeners si es necesario
  }
}

/// Manejador de mensajes en segundo plano (debe estar en nivel superior)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('Mensaje en segundo plano: ${message.messageId}');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
  }
}
