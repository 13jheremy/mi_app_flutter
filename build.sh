#!/bin/bash
# build.sh - Script para builds automatizados

set -e

ENVIRONMENT=${1:-dev}
FLAVOR=${2:-development}

echo "🏗️  Construyendo app para entorno: $ENVIRONMENT, flavor: $FLAVOR"

# Configurar variables de entorno
case $ENVIRONMENT in
    "dev")
        export APP_ENV=dev
        export API_BASE_URL="https://proyecto-2026-ts4b.onrender.com"
        ;;
    "staging")
        export APP_ENV=staging
        export API_BASE_URL="https://staging-proyecto-2026.onrender.com"
        ;;
    "prod")
        export APP_ENV=prod
        export API_BASE_URL="https://proyecto-2026-ts4b.onrender.com"
        ;;
    *)
        echo "❌ Entorno no válido. Use: dev, staging, prod"
        exit 1
        ;;
esac

echo "🌐 API URL: $API_BASE_URL"

# Limpiar builds anteriores
flutter clean

# Obtener dependencias
flutter pub get

# Generar archivos de localización
flutter gen-l10n

# Generar launcher icons
flutter pub run flutter_launcher_icons

# Generar native splash
flutter pub run flutter_native_splash:create

# Ejecutar tests
echo "🧪 Ejecutando tests..."
flutter test

# Build APK
echo "📱 Generando APK..."
flutter build apk --release --flavor $FLAVOR

# Build Bundle (para Play Store)
echo "📦 Generando App Bundle..."
flutter build appbundle --release --flavor $FLAVOR

echo "✅ Build completado exitosamente"
echo "📂 APK: build/app/outputs/flutter-apk/app-release.apk"
echo "📂 Bundle: build/app/outputs/bundle/release/app-release.aab"