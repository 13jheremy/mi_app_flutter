# ProGuard configuration for Flutter app
# This file is used to configure ProGuard for release builds

# Basic Flutter configuration
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase configuration
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# HTTP client
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# JSON parsing
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Keep data classes
-keep class com.example.flutter_final.models.** { *; }
-keep class com.example.flutter_final.services.** { *; }

# Keep provider classes
-keep class com.example.flutter_final.providers.** { *; }

# Obfuscation settings
-dontobfuscate
-dontoptimize
-dontshrink

# Keep line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Play Core / Deferred Components
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }