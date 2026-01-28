// Importamos el paquete de Material Design de Flutter
import 'package:flutter/material.dart';

// Importamos la pantalla de Login que creará el frontend
import 'screens/auth/login_screen.dart';

// ==========================================
// FUNCIÓN PRINCIPAL - Punto de entrada de la app
// ==========================================
void main() {
  runApp(MyApp());  // Ejecuta la aplicación
}

// ==========================================
// CLASE PRINCIPAL DE LA APLICACIÓN
// ==========================================
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'VillaFoodService',// Título de la aplicación (aparece en el task manager)
      
      // Configuración del tema visual de la app
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Color principal azul
      ),
      
      // PANTALLA INICIAL: LoginScreen será lo primero que vea el usuario
      home: LoginScreen(),
      
      // Oculta el banner de "DEBUG" en la esquina
      debugShowCheckedModeBanner: false,
    );
  }
}