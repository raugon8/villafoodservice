import 'package:flutter/material.dart';
// tema principal de la aplicacion con colores accesibles
class app_theme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: const Color(0xFF1A6BB5), // azul accesible (contraste 5.5:1 con texto blanco)
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // blanco general
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A6BB5),
        secondary: Color(0xFFF5C842), // amarillo claro para destacados
        surface: Color(0xFFF2F2F2), // gris claro para tarjetas
        onPrimary: Colors.white, // texto sobre azul
        onSecondary: Color(0xFF212121), // texto oscuro sobre amarillo por contraste (ratio 10.13:1)
        onSurface: Color(0xFF212121), // texto sobre tarjetas
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF212121)), // gris oscuro principal (ratio 16.1:1 sobre blanco)
        bodyMedium: TextStyle(color: Color(0xFF757575)), // gris medio secundario
      ),
    );
  }
}