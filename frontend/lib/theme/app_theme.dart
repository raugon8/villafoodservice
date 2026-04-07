import 'package:flutter/material.dart';

class app_theme {
  // modo claro
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1A6BB5),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A6BB5),
        secondary: Color(0xFFF5C842),
        surface: Color(0xFFF2F2F2),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF212121),
        onSurface: Color(0xFF212121),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF212121)),
        bodyMedium: TextStyle(color: Color(0xFF757575)),
      ),
    );
  }

  // modo oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1A6BB5), // Mantenemos el azul de marca
      scaffoldBackgroundColor: const Color(0xFF121212), // Gris muy oscuro (mejor que negro puro)
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1A6BB5),
        secondary: Color(0xFFF5C842),
        surface: Color(0xFF1E1E1E), // Tarjetas ligeramente más claras que el fondo
        onPrimary: Colors.white,
        onSecondary: Color(0xFF212121),
        onSurface: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFAAAAAA)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 2,
      ),
    );
  }
}