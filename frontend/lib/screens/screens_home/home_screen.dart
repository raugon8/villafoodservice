import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../screens_auth/role_selector_screen.dart';
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

  String _rol_display(String? rol) {
    switch (rol) {
      case 'admin':       return 'Administrador';
      case 'cliente':     return 'Cliente';
      case 'dependiente': return 'Dependiente';
      case 'almacen':     return 'Almacén';
      default:            return 'Sin rol';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<auth_provider>(context);
    final String? rol = auth.current_role;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('villafood', style: TextStyle(fontSize: 16)),
            Text(
              'Sesión como: ${_rol_display(rol)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          if (auth.available_roles.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Cambiar rol',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const role_selector_screen())
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        children: [
          if (rol == 'admin') ...[
            _crear_boton(context, Icons.analytics, 'dashboard', const dashboard_screen()),
            _crear_boton(context, Icons.people, 'usuarios', const user_management_screen()),
            _crear_boton(context, Icons.category, 'categorías', const category_management_screen()),
          ],
          if (rol == 'admin' || rol == 'almacen')
            _crear_boton(context, Icons.kitchen, 'ingredientes', const ingredientes_list_screen()),
          if (rol == 'admin' || rol == 'almacen' || rol == 'dependiente')
            _crear_boton(context, Icons.restaurant_menu, 'productos', const productos_list_screen()),
          _crear_boton(context, Icons.search, 'catálogo', const catalog_screen()),
          _crear_boton(context, Icons.shopping_cart, 'carrito', const cart_screen()),
          _crear_boton(context, Icons.history, 'mis pedidos', const orders_screen()),
          if (rol == 'admin' || rol == 'dependiente')
            _crear_boton(context, Icons.assignment, 'gestión staff', const order_list_screen()),
        ],
      ),
    );
  }

  Widget _crear_boton(BuildContext context, IconData icono, String texto, Widget pantalla) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => pantalla)),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(texto, style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}