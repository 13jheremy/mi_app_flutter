# MotoApp - Gestión para Taller de Motos

Aplicación móvil Flutter para la gestión integral de talleres de motocicletas. Desarrollada con las mejores prácticas de producción y optimizada para Android.

## 📱 Características

- **Autenticación JWT** con refresh tokens
- **Gestión de productos** con inventario y categorías
- **Control de motocicletas** y mantenimientos
- **Sistema de ventas** y reportes
- **Notificaciones push** con Firebase
- **Modo oscuro/claro** automático
- **Internacionalización** (ES/EN)
- **Cache inteligente** de imágenes y datos
- **Analytics y crash reporting**
- **Offline-first** con sincronización

## 🚀 Inicio Rápido

### Prerrequisitos

- Flutter SDK >= 3.8.1
- Dart SDK >= 3.8.1
- Android Studio / VS Code
- Dispositivo Android o emulador

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd mi_app_flutter
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**
   - Copiar `google-services.json` a `android/app/`
   - Configurar proyecto en Firebase Console
   - Habilitar Authentication, Firestore, Cloud Messaging

4. **Configurar iconos y splash**
   ```bash
   # Reemplazar placeholders en assets/icons/
   # app_icon.png (1024x1024)
   # app_icon_foreground.png (432x432)
   # splash_icon.png

   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

5. **Generar traducciones**
   ```bash
   flutter gen-l10n
   ```

### Configuración de Entornos

La app soporta múltiples entornos:

- **Dev**: Desarrollo local
- **Staging**: Pruebas de integración
- **Prod**: Producción

```bash
# Build para desarrollo
./build.sh dev development

# Build para producción
./build.sh prod production
```

## 🧪 Testing

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests con cobertura
flutter test --coverage

# Tests de integración
flutter test integration_test/
```

### Análisis de Código
```bash
# Análisis estático
flutter analyze

# Análisis completo
./analyze.sh
```

## 📦 Build y Release

### Build APK
```bash
flutter build apk --release
```

### Build App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### Configuración de Play Store

1. **Crear cuenta de desarrollador** en Google Play Console
2. **Subir bundle** generado
3. **Configurar store listing**:
   - Título: MotoApp
   - Descripción corta y completa
   - Capturas de pantalla (6-8 imágenes)
   - Icono de feature graphic (1024x500)
4. **Configurar precios y distribución**
5. **Publicar en testing track** primero

## 🔧 Configuración

### Variables de Entorno

Crear archivo `.env` en la raíz:

```env
# API Configuration
API_BASE_URL=https://proyecto-2026-ts4b.onrender.com
API_TIMEOUT=30

# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
SENTRY_DSN=your-sentry-dsn

# App Configuration
APP_ENV=prod
ENABLE_LOGGING=false
ENABLE_CRASH_REPORTING=true
```

### Firebase Setup

1. **Crear proyecto** en Firebase Console
2. **Habilitar servicios**:
   - Authentication (Email/Password)
   - Cloud Messaging (Push Notifications)
   - Crashlytics
   - Analytics
3. **Descargar configuración**:
   - `google-services.json` → `android/app/`
4. **Configurar FCM** en el backend

### Sentry Setup (Opcional)

1. **Crear proyecto** en Sentry.io
2. **Obtener DSN**
3. **Configurar en main.dart**:
   ```dart
   options.dsn = 'YOUR_SENTRY_DSN_HERE';
   ```

## 🏗️ Arquitectura

```
lib/
├── config/           # Configuración global
│   ├── api_config.dart
│   ├── environments.dart
│   └── theme.dart
├── models/           # Modelos de datos
├── providers/        # State management
├── screens/          # Pantallas UI
├── services/         # Lógica de negocio
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── cache_service.dart
│   ├── image_cache_service.dart
│   ├── analytics_service.dart
│   └── notification_service.dart
├── widgets/          # Componentes reutilizables
├── l10n/            # Internacionalización
└── utils/           # Utilidades
```

## 📊 Analytics y Monitoreo

### Firebase Analytics
- Tracking automático de pantallas
- Eventos personalizados de usuario
- Conversión de compras
- Retención de usuarios

### Crashlytics
- Reportes automáticos de crashes
- Logs de errores no fatales
- Información de dispositivos
- Trazas de pila detalladas

## 🔒 Seguridad

- **Ofuscación de código** activada en release
- **Certificate pinning** para APIs
- **Secure storage** para tokens sensibles
- **Encriptación** de datos locales
- **Validación** de inputs

## 🌐 Internacionalización

Soporte completo para:
- Español (ES)
- Inglés (EN)

Archivos de traducción en `lib/l10n/`

## 📱 Optimizaciones

- **Cache inteligente** de imágenes
- **Lazy loading** en listas
- **Compresión** de assets
- **Tree shaking** automático
- **Split-debug-info** para debugging

## 🐛 Troubleshooting

### Problemas Comunes

1. **Build falla**
   ```bash
   flutter clean
   flutter pub get
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

2. **Firebase no funciona**
   - Verificar `google-services.json`
   - Revisar configuración en Firebase Console
   - Verificar permisos de red

3. **Notificaciones no llegan**
   - Verificar configuración FCM en backend
   - Revisar permisos de notificaciones
   - Verificar token FCM

### Logs de Debug

```bash
# Ver logs detallados
flutter logs

# Ver logs de red
flutter run --verbose
```

## 📝 Scripts Disponibles

- `analyze.sh` - Análisis completo de código
- `build.sh` - Build automatizado para diferentes entornos
- `flutter pub run flutter_launcher_icons` - Generar iconos
- `flutter pub run flutter_native_splash:create` - Generar splash

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 📞 Soporte

Para soporte técnico:
- Crear issue en GitHub
- Revisar documentación
- Contactar al equipo de desarrollo

---

**Versión**: 1.0.0+1
**Última actualización**: Abril 2026
**Flutter**: >=3.8.1
**Android**: API 23+
