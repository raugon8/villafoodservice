import 'package:flutter/material.dart';
import '../screens_ingredientes/ingredientes_list_screen.dart';
import '../screens_productos/productos_list_screen.dart';
import '../screens_client/cart_screen.dart';
import '../screens_client/orders_screen.dart';
import '../screens_staff/order_list_screen.dart';

class home_screen extends StatelessWidget {
  const home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('villafood - menu principal')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        children: [
          // gestion de ingredientes (tarea 3)
          _crear_boton(context, Icons.kitchen, 'ingredientes', const ingredientes_list_screen()),

          // gestion de productos (tarea 4)
          _crear_boton(context, Icons.restaurant_menu, 'productos', const productos_list_screen()),

          // carrito de compras (tarea 5)
          _crear_boton(context, Icons.shopping_cart, 'carrito', cart_screen()),

          // mis pedidos - cliente (tarea 5)
          _crear_boton(context, Icons.history, 'mis pedidos', orders_screen()),

          // gestion pedidos - staff (tarea 6)
          _crear_boton(context, Icons.assignment, 'gestion staff', const order_list_screen()),
        ],
      ),
    );
  }

  Widget _crear_boton(BuildContext context, IconData icono, String texto, Widget pantalla) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => pantalla)),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icono, size: 40), Text(texto)],
        ),
      ),
    );
  }
}