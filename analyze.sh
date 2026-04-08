#!/bin/bash
# analyze.sh - Script para análisis de código y testing

echo "🚀 Iniciando análisis de código..."

# Ejecutar flutter analyze
echo "📊 Ejecutando flutter analyze..."
flutter analyze

# Ejecutar tests
echo "🧪 Ejecutando tests..."
flutter test --coverage

# Verificar cobertura de código
echo "📈 Verificando cobertura de tests..."
if [ -d "coverage" ]; then
    echo "Cobertura generada en coverage/lcov.info"
    # Instalar lcov si no está disponible
    if command -v lcov &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        echo "Reporte HTML generado en coverage/html/index.html"
    fi
else
    echo "⚠️  No se pudo generar reporte de cobertura"
fi

# Verificar tamaño del APK
echo "📱 Verificando tamaño del build..."
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    apk_size=$(stat -f%z build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || stat -c%s build/app/outputs/flutter-apk/app-release.apk 2>/dev/null)
    apk_size_mb=$((apk_size / 1024 / 1024))
    echo "Tamaño del APK: ${apk_size_mb}MB"
    if [ $apk_size_mb -gt 50 ]; then
        echo "⚠️  APK muy grande (>50MB). Considera optimizar assets."
    fi
else
    echo "ℹ️  No se encontró APK de release. Ejecuta 'flutter build apk --release' para generar uno."
fi

echo "✅ Análisis completado"