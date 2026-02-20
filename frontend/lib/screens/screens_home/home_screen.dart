import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; 
import '../screens_ingredientes/ingredientes_list_screen.dart'; 
import '../screens_productos/productos_list_screen.dart';
import '../screens_client/cart_screen.dart'; 
import '../screens_client/orders_screen.dart'; 
import '../screens_staff/order_list_screen.dart'; 
import '../admin/dashboard_screen.dart'; 
import '../admin/user_management_screen.dart'; 

class home_screen extends StatelessWidget {
  const home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    // leemos el rol activo del usuario
    final auth = Provider.of<auth_provider>(context);
    final String? rol = auth.current_role;

    return Scaffold(
      appBar: AppBar(title: const Text('villafood - menu principal')),
      body: GridView.count(
        crossAxisCount: 2, 
        padding: const EdgeInsets.all(20),
        children: [
          // dashboard estadisticas - solo admin
          if (rol == 'admin')
            _crear_boton(context, Icons.analytics, 'dashboard', const dashboard_screen()),

          // gestion de usuarios - solo admin
          if (rol == 'admin')
            _crear_boton(context, Icons.people, 'usuarios', const user_management_screen()),

          // gestion de ingredientes - admin o almacen
          if (rol == 'admin' || rol == 'almacen')
            _crear_boton(context, Icons.kitchen, 'ingredientes', const ingredientes_list_screen()),
          
          // gestion de productos - admin, almacen o dependiente
          if (rol == 'admin' || rol == 'almacen' || rol == 'dependiente')
            _crear_boton(context, Icons.restaurant_menu, 'productos', const productos_list_screen()),
          
          // carrito de compras - todos
          _crear_boton(context, Icons.shopping_cart, 'carrito', const cart_screen()),
          
          // mis pedidos - cliente
          _crear_boton(context, Icons.history, 'mis pedidos', const orders_screen()),
          
          // gestion pedidos - staff - admin o dependiente
          if (rol == 'admin' || rol == 'dependiente')
            _crear_boton(context, Icons.assignment, 'gestion staff', const order_list_screen()),
        ],
      ),
    );
  }

  // funcion auxiliar original intacta
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