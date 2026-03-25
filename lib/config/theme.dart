// lib/config/theme.dart
// Define el tema visual de la aplicación.
// ----------------------------------------
import 'package:flutter/material.dart';

class AppTheme {
  // Colores base según el diseño del frontend
  static const Color _primaryRed = Color(0xFFDC2626); // bg-red-600
  static const Color _darkPrimaryRed = Color(
    0xFFB91C1C,
  ); // bg-red-700 (hover state)
  static const Color _lightScaffoldBackground = Color(
    0xFFf8fafc,
  ); // bg-gray-100
  static const Color _darkScaffoldBackground = Color(0xFF111827); // bg-gray-900
  static const Color _lightCardColor = Colors.white; // bg-white
  static const Color _darkCardColor = Color(0xFF1f2937); // bg-gray-800
  static const Color _lightTextColor = Color(0xFF1e293b); // text-gray-900
  static const Color _darkTextColor = Color(0xFFf3f4f6); // text-gray-100
  static const Color _lightSubtitleColor = Color(0xFF64748b); // text-gray-600
  static const Color _darkSubtitleColor = Color(0xFF9ca3af); // text-gray-400

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryRed,
    primarySwatch: MaterialColor(_primaryRed.value, {
      50: _primaryRed.withOpacity(0.1),
      100: _primaryRed.withOpacity(0.2),
      200: _primaryRed.withOpacity(0.3),
      300: _primaryRed.withOpacity(0.4),
      400: _primaryRed.withOpacity(0.5),
      500: _primaryRed.withOpacity(0.6),
      600: _primaryRed.withOpacity(0.7),
      700: _primaryRed.withOpacity(0.8),
      800: _primaryRed.withOpacity(0.9),
      900: _primaryRed.withOpacity(1.0),
    }),
    scaffoldBackgroundColor: _lightScaffoldBackground,
    cardColor: _lightCardColor,
    appBarTheme: AppBarTheme(
      color: _primaryRed,
      elevation: 4.0, // Añade sombra
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _lightTextColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: _lightSubtitleColor),
      bodyMedium: TextStyle(fontSize: 14, color: _lightSubtitleColor),
      bodySmall: TextStyle(fontSize: 12, color: _lightSubtitleColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryRed, // Usar un rojo más oscuro para FAB
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _primaryRed,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ), // px-4 py-2, px-3 py-2
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // rounded-md
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 2, // shadow-sm
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryRed,
        textStyle: const TextStyle(fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100], // bg-white
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // rounded-md
        borderSide: BorderSide.none, // border border-gray-300
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _primaryRed,
          width: 2,
        ), // focus:ring-2 focus:ring-red-500 focus:border-red-500
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ), // border-red-300
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ), // px-3 py-2
      hintStyle: TextStyle(color: Colors.grey[500]), // placeholder-gray-500
      labelStyle: TextStyle(color: Colors.grey[700]), // text-gray-700
    ),
    // Añadir más estilos según sea necesario (ej. para badges, tablas)
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryRed,
    primarySwatch: MaterialColor(_darkPrimaryRed.value, {
      50: _darkPrimaryRed.withOpacity(0.1),
      100: _darkPrimaryRed.withOpacity(0.2),
      200: _darkPrimaryRed.withOpacity(0.3),
      300: _darkPrimaryRed.withOpacity(0.4),
      400: _darkPrimaryRed.withOpacity(0.5),
      500: _darkPrimaryRed.withOpacity(0.6),
      600: _darkPrimaryRed.withOpacity(0.7),
      700: _darkPrimaryRed.withOpacity(0.8),
      800: _darkPrimaryRed.withOpacity(0.9),
      900: _darkPrimaryRed.withOpacity(1.0),
    }),
    scaffoldBackgroundColor: _darkScaffoldBackground, // bg-gray-900
    cardColor: _darkCardColor, // bg-gray-800
    appBarTheme: AppBarTheme(
      color: _darkPrimaryRed,
      elevation: 4.0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _darkTextColor, // text-gray-100
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _darkSubtitleColor,
      ), // text-gray-400
      bodyMedium: TextStyle(fontSize: 14, color: _darkSubtitleColor),
      bodySmall: TextStyle(fontSize: 12, color: _darkSubtitleColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryRed,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _darkPrimaryRed,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimaryRed,
        textStyle: const TextStyle(fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[700], // bg-gray-700
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[600]!), // border-gray-600
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkPrimaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: Colors.grey[400]), // placeholder-gray-400
      labelStyle: TextStyle(color: Colors.grey[300]), // text-gray-300
    ),
  );
}
