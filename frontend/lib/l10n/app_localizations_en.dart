// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login_titulo => 'Sign in';

  @override
  String get login_email => 'Email address';

  @override
  String get login_password => 'Password';

  @override
  String get login_boton => 'Sign in';

  @override
  String get login_registro => 'Don\'t have an account? Sign up';

  @override
  String get catalogo_titulo => 'Catalogue';

  @override
  String get carrito_titulo => 'My cart';

  @override
  String get carrito_confirmar => 'Confirm order';

  @override
  String get carrito_vacio => 'Your cart is empty';

  @override
  String get pedidos_titulo => 'My orders';

  @override
  String get error_conexion => 'Connection error. Please try again.';

  @override
  String get error_campos => 'Please fill in all fields';

  @override
  String get boton_reintentar => 'Retry';

  @override
  String get catalogo_buscar => 'Search product or ingredient...';

  @override
  String get catalogo_ordenar => 'Sort';

  @override
  String get catalogo_todas => 'All';

  @override
  String get catalogo_sin_resultados => 'No results found';

  @override
  String get catalogo_sin_stock => 'Out of stock';

  @override
  String get catalogo_uds => 'units';

  @override
  String get catalogo_anadido => 'added to cart';

  @override
  String get sort_nombre_az => 'Name A-Z';

  @override
  String get sort_nombre_za => 'Name Z-A';

  @override
  String get sort_precio_asc => 'Price low-high';

  @override
  String get sort_precio_desc => 'Price high-low';

  @override
  String get sort_disponibles => 'Available first';

  @override
  String get sort_vendidos => 'Best sellers';

  @override
  String get pedidos_vacio => 'You haven\'t placed any orders yet';

  @override
  String get pedidos_numero => 'Order #';

  @override
  String get pedidos_estado => 'Status:';

  @override
  String get pedidos_total => 'Total:';

  @override
  String get home_sesion_como => 'Session as: ';

  @override
  String get home_rol_admin => 'Administrator';

  @override
  String get home_rol_cliente => 'Customer';

  @override
  String get home_rol_dependiente => 'Clerk';

  @override
  String get home_rol_almacen => 'Warehouse';

  @override
  String get home_rol_sin_rol => 'No role';

  @override
  String get home_cambiar_rol => 'Change role';

  @override
  String get home_cerrar_sesion => 'Log out';

  @override
  String get home_btn_dashboard => 'Dashboard';

  @override
  String get home_desc_dashboard => 'View general statistics';

  @override
  String get home_btn_usuarios => 'Users';

  @override
  String get home_desc_usuarios => 'Manage user accounts';

  @override
  String get home_btn_categorias => 'Categories';

  @override
  String get home_desc_categorias => 'Manage product categories';

  @override
  String get home_btn_ingredientes => 'Ingredients';

  @override
  String get home_desc_ingredientes => 'Manage ingredient stock';

  @override
  String get home_btn_productos => 'Products';

  @override
  String get home_desc_productos => 'Manage product catalog';

  @override
  String get home_btn_catalogo => 'Catalogue';

  @override
  String get home_desc_catalogo => 'Search and filter products';

  @override
  String get home_btn_carrito => 'Cart';

  @override
  String get home_desc_carrito => 'View selected products to buy';

  @override
  String get home_btn_pedidos => 'My orders';

  @override
  String get home_desc_pedidos => 'View purchase history';

  @override
  String get home_btn_staff => 'Staff Management';

  @override
  String get home_desc_staff => 'Order preparation panel';

  @override
  String get reg_faltan_datos => 'Missing data';

  @override
  String get reg_creado => 'Created: ';

  @override
  String get reg_titulo => 'Register';

  @override
  String get reg_nombre => 'Name';

  @override
  String get reg_email => 'Email';

  @override
  String get reg_pass => 'Password';

  @override
  String get reg_crear => 'Create';

  @override
  String get reg_atras => 'Back';

  @override
  String get cart_confirmado_tit => 'Order confirmed!';

  @override
  String get cart_aceptar => 'Accept';

  @override
  String get cart_vaciar => 'Empty';

  @override
  String get cart_ud => '/ unit';

  @override
  String get cart_notas => 'Order notes (optional)';

  @override
  String get cart_productos_count => 'products';

  @override
  String get det_alergenos_tit => 'Declared allergens:';

  @override
  String get det_sin_alergenos => 'No allergens declared';

  @override
  String get det_add_carrito => 'Add to cart';

  @override
  String get det_agotado => 'Out of stock';
}
