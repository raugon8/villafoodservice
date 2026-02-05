import 'package:flutter/material.dart';
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
    // configuracion basica de la aplicacion
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'villafood service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // define el login como punto de partida
      home: const login_screen(),
    );
  }
}