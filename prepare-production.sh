#!/bin/bash
# prepare-production.sh - Script para preparar la app para producción

set -e

echo "🚀 Preparando MotoApp para producción..."

# Verificar Flutter
echo "📱 Verificando Flutter..."
flutter --version
flutter doctor

# Limpiar proyecto
echo "🧹 Limpiando proyecto..."
flutter clean

# Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

# Verificar configuración de Firebase
echo "🔥 Verificando Firebase..."
if [ ! -f "android/app/google-services.json" ]; then
    echo "❌ ERROR: google-services.json no encontrado en android/app/"
    echo "   Descárgalo desde Firebase Console y colócalo en android/app/google-services.json"
    exit 1
fi

# Verificar iconos de app
echo "🎨 Verificando iconos de app..."
if [ ! -f "assets/icons/app_icon.png" ] || [ ! -f "assets/icons/app_icon_foreground.png" ] || [ ! -f "assets/icons/splash_icon.png" ]; then
    echo "⚠️  ADVERTENCIA: Iconos de app no encontrados"
    echo "   Reemplaza los placeholders en assets/icons/ con tus iconos reales"
    echo "   - app_icon.png (1024x1024)"
    echo "   - app_icon_foreground.png (432x432)"
    echo "   - splash_icon.png"
fi

# Generar archivos de localización
echo "🌐 Generando traducciones..."
flutter gen-l10n

# Generar iconos de launcher
echo "📱 Generando iconos de launcher..."
flutter pub run flutter_launcher_icons

# Generar splash screen
echo "💫 Generando splash screen..."
flutter pub run flutter_native_splash:create

# Ejecutar análisis de código
echo "📊 Ejecutando análisis de código..."
flutter analyze

# Ejecutar tests
echo "🧪 Ejecutando tests..."
flutter test

# Verificar builds
echo "🏗️  Verificando builds..."

echo "  📱 Build APK..."
flutter build apk --release --split-debug-info=build/app/outputs/symbols

echo "  📦 Build App Bundle..."
flutter build appbundle --release --split-debug-info=build/app/outputs/symbols

# Verificar tamaños
echo "📏 Verificando tamaños..."
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    apk_size=$(stat -f%z build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || stat -c%s build/app/outputs/flutter-apk/app-release.apk 2>/dev/null)
    apk_size_mb=$((apk_size / 1024 / 1024))
    echo "  📱 APK: ${apk_size_mb}MB"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    aab_size=$(stat -f%z build/app/outputs/bundle/release/app-release.aab 2>/dev/null || stat -c%s build/app/outputs/bundle/release/app-release.aab 2>/dev/null)
    aab_size_mb=$((aab_size / 1024 / 1024))
    echo "  📦 AAB: ${aab_size_mb}MB"
fi

echo ""
echo "✅ Preparación completada!"
echo ""
echo "📋 Checklist final:"
echo "  ✅ Firebase configurado"
echo "  ✅ Iconos generados"
echo "  ✅ Traducciones generadas"
echo "  ✅ Tests pasados"
echo "  ✅ Análisis de código OK"
echo "  ✅ Builds generados"
echo ""
echo "🎯 La app está lista para subir a Play Store!"
echo ""
echo "📂 Archivos generados:"
echo "  📱 APK: build/app/outputs/flutter-apk/app-release.apk"
echo "  📦 AAB: build/app/outputs/bundle/release/app-release.aab"
echo "  🐛 Símbolos: build/app/outputs/symbols/"