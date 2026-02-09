// Importamos el paquete de Material Design de Flutter
import 'package:flutter/material.dart';
import 'package:villafood_frontend/screens_home/home_screen.dart';
import 'screens_auth/login_screen.dart'; // carga la pantalla inicial

void main() => run_app();

// funcion de inicio sin mayusculas
void run_app() {
  runApp(const mi_app());
}

class mi_app extends StatelessWidget {
  const mi_app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'VillaFoodService',// Título de la aplicación (aparece en el task manager)
      
      // Configuración del tema visual de la app
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Color principal azul
      ),
      // define el login como punto de partida
      home: const home_screen(),
    );
  }
}