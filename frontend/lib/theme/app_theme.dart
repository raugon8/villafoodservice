import 'package:flutter/material.dart';

class app_theme {
  static ThemeData get light_theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3), // azul corporativo
        // Esta es la línea que arregla tu widget
        surfaceContainerHighest: const Color(0xFFF0F2F5), 
      ),
    );
  }
}