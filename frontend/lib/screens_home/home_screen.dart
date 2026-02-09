import 'package:flutter/material.dart';
import '../screens_ingredientes/ingredientes_list_screen.dart';
import '../screens_productos/productos_list_screen.dart';

class home_screen extends StatelessWidget {
  const home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('villafood - menu principal')),
      body: GridView.count(
        crossAxisCount: 2, // rejilla de dos columnas
        padding: const EdgeInsets.all(20),
        children: [
          // boton para ir a ingredientes
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ingredientes_list_screen())),
            child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.kitchen, size: 50), Text('ingredientes')])),
          ),
          // boton para ir a productos
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const productos_list_screen())),
            child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.restaurant_menu, size: 50), Text('productos')])),
          ),
        ],
      ),
    );
  }
}