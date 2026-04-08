import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/text_scale_toggle.dart';
import '../../screens/screens_auth/role_selector_screen.dart';
import '../../screens/screens_auth/login_screen.dart';
import '../../screens/screens_ingredientes/ingredientes_list_screen.dart';
import '../../screens/screens_productos/productos_list_screen.dart';
import '../../screens/screens_client/cart_screen.dart';
import '../../screens/screens_client/catalog_screen.dart';
import '../../screens/screens_client/historial_screen.dart';
import '../../screens/screens_staff/order_list_screen.dart';
import '../../screens/admin/dashboard_screen.dart';
import '../../screens/admin/category_management_screen.dart';
import '../../screens/admin/user_management_screen.dart';

/// pantalla principal que filtra opciones segun el rol del usuario
class home_screen extends StatelessWidget {
  const home_screen({super.key});

  /// formatea el nombre del rol para mostrarlo en la interfaz
  ///
  /// args:
  ///   rol (String?): el rol actual del usuario en formato de base de datos
  String _rol_display(String? rol, AppLocalizations loc) {
    switch (rol) {
      case 'admin':       return loc.home_rol_admin;
      case 'cliente':     return loc.home_rol_cliente;
      case 'dependiente': return loc.home_rol_dependiente;
      case 'almacen':     return loc.home_rol_almacen;
      default:            return loc.home_rol_sin_rol;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<auth_provider>(context);
    final theme_prov = Provider.of<theme_provider>(context);
    final loc = AppLocalizations.of(context)!;
    final String? rol = auth.current_role;
    // responsive: 4 columnas en web/tablet, 2 en movil
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // logo de la app en el appbar
            Image.asset(
              'assets/logo.png',
              height: 36,
              errorBuilder: (c, e, s) => const Icon(Icons.restaurant, size: 36),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VillaFood', style: TextStyle(fontSize: 16)),
                Text(
                  '${loc.home_sesion_como}${_rol_display(rol, loc)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // boton modo oscuro/claro
          IconButton(
            icon: Icon(theme_prov.is_dark_mode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Cambiar tema',
            onPressed: () => theme_prov.toggle_theme(),
          ),
          const text_scale_toggle(),
          if (auth.available_roles.length > 1)
            IconButton(
              icon: const Icon(Icons.switch_account),
              tooltip: loc.home_cambiar_rol,
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const role_selector_screen())
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: loc.home_cerrar_sesion,
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
      body: Center(
        child: ConstrainedBox(
          // tope de 1200px para que no se estire demasiado en pantallas grandes
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GridView.count(
            crossAxisCount: isDesktop ? 4 : 2,
            childAspectRatio: isDesktop ? 1.3 : 1.0,
            padding: const EdgeInsets.all(20),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              if (rol == 'admin') ...[
                _crear_boton(context, Icons.analytics, loc.home_btn_dashboard, loc.home_desc_dashboard, const dashboard_screen()),
                _crear_boton(context, Icons.people, loc.home_btn_usuarios, loc.home_desc_usuarios, const user_management_screen()),
                _crear_boton(context, Icons.category, loc.home_btn_categorias, loc.home_desc_categorias, const category_management_screen()),
              ],

              if (rol == 'admin' || rol == 'almacen')
                _crear_boton(context, Icons.kitchen, loc.home_btn_ingredientes, loc.home_desc_ingredientes, const ingredientes_list_screen()),

              if (rol == 'admin' || rol == 'almacen' || rol == 'dependiente')
                _crear_boton(context, Icons.restaurant_menu, loc.home_btn_productos, loc.home_desc_productos, const productos_list_screen()),

              // el cliente y el admin ven estos botones; dependiente y almacen no pueden hacer pedidos
              if (rol == 'cliente' || rol == 'admin')
                _crear_boton(context, Icons.search, loc.home_btn_catalogo, loc.home_desc_catalogo, const catalog_screen()),

              if (rol == 'cliente' || rol == 'admin')
                _crear_boton(context, Icons.shopping_cart, loc.home_btn_carrito, loc.home_desc_carrito, const cart_screen()),

              // boton de historial, solo visible para clientes y admin
              if (rol == 'cliente' || rol == 'admin')
                _crear_boton(context, Icons.history, loc.home_btn_pedidos, loc.home_desc_pedidos, const historial_screen()),

              if (rol == 'admin' || rol == 'dependiente')
                _crear_boton(context, Icons.assignment, loc.home_btn_staff, loc.home_desc_staff, const order_list_screen()),
            ],
          ),
        ),
      ),
    );
  }

  /// construye botones con soporte para lectores de pantalla
  ///
  /// args:
  ///   context (BuildContext): el arbol de widgets actual
  ///   icono (IconData): icono visual del boton
  ///   texto (String): titulo corto del boton
  ///   label_accesibilidad (String): descripcion larga para el lector de pantalla
  ///   pantalla (Widget): pantalla destino a la que navega
  Widget _crear_boton(BuildContext context, IconData icono, String texto, String label_accesibilidad, Widget pantalla) {
    return Semantics(
      label: label_accesibilidad,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => pantalla)),
          excludeFromSemantics: true,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, size: 48, color: Theme.of(context).primaryColor),
                const SizedBox(height: 12),
                Text(
                  texto,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}