import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/text_scale_toggle.dart';
import '../../screens/screens_auth/role_selector_screen.dart';
import '../../screens/screens_auth/login_screen.dart';
import '../../screens/screens_ingredientes/ingredientes_list_screen.dart';
import '../../screens/screens_productos/productos_list_screen.dart';
import '../../screens/screens_client/cart_screen.dart';
import '../../screens/screens_client/orders_screen.dart';
import '../../screens/screens_client/catalog_screen.dart';
import '../../screens/screens_staff/order_list_screen.dart';
import '../../screens/admin/dashboard_screen.dart';
import '../../screens/admin/category_management_screen.dart';
import '../../screens/admin/user_management_screen.dart';

// pantalla principal que filtra opciones segun el rol del usuario
class home_screen extends StatelessWidget {
  const home_screen({super.key});

  // formatea el nombre del rol para mostrarlo en la interfaz
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
              'sesion como: ${_rol_display(rol)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // toggle para accesibilidad de tamaño de texto
          const text_scale_toggle(),
          
          if (auth.available_roles.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'cambiar rol',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const role_selector_screen())
              ),
            ),
          
          // boton de cierre de sesion con navegacion directa
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'cerrar sesion',
            onPressed: () {
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const login_screen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        children: [
          // bloques condicionales segun permisos del usuario
          if (rol == 'admin') ...[
            _crear_boton(context, Icons.analytics, 'dashboard', 'ver estadisticas generales', const dashboard_screen()),
            _crear_boton(context, Icons.people, 'usuarios', 'gestionar cuentas de usuario', const user_management_screen()),
            _crear_boton(context, Icons.category, 'categorias', 'gestionar categorias de productos', const category_management_screen()),
          ],
          
          if (rol == 'admin' || rol == 'almacen')
            _crear_boton(context, Icons.kitchen, 'ingredientes', 'gestionar existencias de ingredientes', const ingredientes_list_screen()),
          
          if (rol == 'admin' || rol == 'almacen' || rol == 'dependiente')
            _crear_boton(context, Icons.restaurant_menu, 'productos', 'gestionar catalogo de productos', const productos_list_screen()),
          
          _crear_boton(context, Icons.search, 'catalogo', 'buscar y filtrar productos', const catalog_screen()),
          _crear_boton(context, Icons.shopping_cart, 'carrito', 'ver productos seleccionados para comprar', const cart_screen()),
          _crear_boton(context, Icons.history, 'mis pedidos', 'ver historial de compras realizadas', const orders_screen()),
          
          if (rol == 'admin' || rol == 'dependiente')
            _crear_boton(context, Icons.assignment, 'gestion staff', 'panel de preparacion de pedidos', const order_list_screen()),
        ],
      ),
    );
  }

  // construye botones con soporte para lectores de pantalla
  Widget _crear_boton(BuildContext context, IconData icono, String texto, String label_accesibilidad, Widget pantalla) {
    return Semantics(
      label: label_accesibilidad,
      button: true,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => pantalla)),
        excludeFromSemantics: true,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(texto, style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}