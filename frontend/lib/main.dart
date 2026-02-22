
import 'package:flutter/material.dart';
import 'package:villafood_frontend/screens_home/home_screen.dart';
import 'screens_auth/login_screen.dart'; 

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
      
      title: 'VillaFoodService',
      
      
      theme: ThemeData(
        primarySwatch: Colors.blue, 
      ),
      // define el login como punto de partida
      home: const home_screen(),
    );
  }
}