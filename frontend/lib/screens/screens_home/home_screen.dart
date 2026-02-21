import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../screens_ingredientes/ingredientes_list_screen.dart';
import '../screens_productos/productos_list_screen.dart';
import '../screens_client/cart_screen.dart';
import '../screens_client/orders_screen.dart';
import '../screens_client/catalog_screen.dart'; 
import '../screens_staff/order_list_screen.dart';
import '../admin/dashboard_screen.dart';
import '../admin/category_management_screen.dart';
import '../admin/user_management_screen.dart';

class home_screen extends StatelessWidget {
  const home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    // leemos el rol para que los "if" funcionen
    final auth = Provider.of<auth_provider>(context);
    final String? rol = auth.current_role;

    return Scaffold(
      appBar: AppBar(title: const Text('villafood - menu principal')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        children: [
          // gestion de usuarios y dashboard - solo admin
          if (rol == 'admin') ...[
            _crear_boton(context, Icons.analytics, 'dashboard', const dashboard_screen()),
            _crear_boton(context, Icons.people, 'usuarios', const user_management_screen()),
            _crear_boton(context, Icons.category, 'categorias', const category_management_screen()),
          ],

          // gestion de ingredientes - admin o almacen
          if (rol == 'admin' || rol == 'almacen')
            _crear_boton(context, Icons.kitchen, 'ingredientes', const ingredientes_list_screen()),
          
          // gestion de productos interna - admin, almacen o dependiente
          if (rol == 'admin' || rol == 'almacen' || rol == 'dependiente')
            _crear_boton(context, Icons.restaurant_menu, 'productos', const productos_list_screen()),
          
          // NUEVO: Catálogo de clientes con el buscador de la Tarea 9 (Siempre visible)
          _crear_boton(context, Icons.search, 'catálogo', const catalog_screen()),

          // carrito y mis pedidos - siempre visibles
          _crear_boton(context, Icons.shopping_cart, 'carrito', const cart_screen()),
          _crear_boton(context, Icons.history, 'mis pedidos', const orders_screen()),
          
          // gestion staff - admin o dependiente
          if (rol == 'admin' || rol == 'dependiente')
            _crear_boton(context, Icons.assignment, 'gestion staff', const order_list_screen()),
        ],
      ),
    );
  }

  // tu funcion de siempre, con el color corregido para la Tarea 10
  Widget _crear_boton(BuildContext context, IconData icono, String texto, Widget pantalla) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => pantalla)),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 40, color: Theme.of(context).primaryColor), // Le damos el azul corporativo al icono
            const SizedBox(height: 8),
            Text(texto, style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}