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

  @override
  String get role_selector_title => 'Select your role';

  @override
  String get dash_title => 'Administrative Panel';

  @override
  String get dash_tooltip_users => 'Manage users';

  @override
  String get dash_period_label => 'Period';

  @override
  String get dash_period_all => 'All history';

  @override
  String get dash_period_today => 'Today';

  @override
  String get dash_period_week => 'Last week';

  @override
  String get dash_period_month => 'Last month';

  @override
  String get dash_period_6months => 'Last 6 months';

  @override
  String get dash_period_custom => 'Custom';

  @override
  String get dash_date_start => 'Start date';

  @override
  String get dash_date_end => 'End date';

  @override
  String get dash_del => 'From ';

  @override
  String get dash_al => ' to ';

  @override
  String get dash_sec_pedidos => 'Orders';

  @override
  String get dash_card_total => 'Total';

  @override
  String get dash_card_pendientes => 'Pending';

  @override
  String get dash_card_preparacion => 'In preparation';

  @override
  String get dash_card_listos => 'Ready';

  @override
  String get dash_card_entregados => 'Delivered';

  @override
  String get dash_card_cancelados => 'Cancelled';

  @override
  String get dash_sec_ventas => 'Sales';

  @override
  String get dash_card_ingresos => 'Revenue';

  @override
  String get dash_card_completados => 'Completed';

  @override
  String get dash_card_ticket => 'Average ticket';

  @override
  String get dash_sec_productos => 'Products';

  @override
  String get dash_card_activos => 'Active';

  @override
  String get dash_card_sinstock => 'Out of stock';

  @override
  String get dash_card_desactivados => 'Deactivated';

  @override
  String get dash_card_vendidos => ' sold';

  @override
  String get dash_sec_ingredientes => 'Ingredients';

  @override
  String get dash_card_stockcritico => 'Critical stock';

  @override
  String get dash_card_stockbajo => 'Low stock';

  @override
  String get dash_sec_usuarios => 'Users';

  @override
  String get dash_card_admins => 'Admins';

  @override
  String get dash_card_clientes => 'Customers';

  @override
  String get dash_card_dependientes => 'Clerks';

  @override
  String get dash_card_almacen => 'Warehouse';

  @override
  String get dash_stat_all => 'All history statistics';

  @override
  String get dash_stat_del => 'Statistics from ';

  @override
  String get user_mgr_title => 'User Management';

  @override
  String get user_mgr_create_title => 'Create user';

  @override
  String get user_mgr_edit_title => 'Edit user';

  @override
  String get user_mgr_name => 'Full name';

  @override
  String get user_mgr_email => 'Email';

  @override
  String get user_mgr_pass => 'Password';

  @override
  String get user_mgr_new_pass => 'New password (optional)';

  @override
  String get user_mgr_roles => 'Roles:';

  @override
  String get user_mgr_cancel => 'Cancel';

  @override
  String get user_mgr_create_btn => 'Create';

  @override
  String get user_mgr_save_btn => 'Save';

  @override
  String get user_mgr_err_name_email => 'Name and email are required';

  @override
  String get user_mgr_err_roles => 'Select at least one role';

  @override
  String get user_mgr_err_pass => 'Password is required';

  @override
  String get user_mgr_msg_created => 'User successfully created';

  @override
  String get user_mgr_msg_updated => 'User successfully updated';

  @override
  String get cat_title => 'category management';

  @override
  String get cat_new => 'new category';

  @override
  String get cat_edit => 'edit category';

  @override
  String get cat_name => 'name *';

  @override
  String get cat_desc => 'description';

  @override
  String get cat_cancel => 'cancel';

  @override
  String get cat_save => 'save';

  @override
  String get cat_empty => 'no categories';

  @override
  String get ing_list_title => 'ingredient management';

  @override
  String get ing_list_empty => 'no ingredients';

  @override
  String get ing_list_stock => 'stock: ';

  @override
  String get ing_list_weight => 'weighed in: ';

  @override
  String get ing_list_delete_title => 'delete ingredient';

  @override
  String get ing_list_delete_msg => 'delete';

  @override
  String get ing_list_deleted => 'ingredient deleted';

  @override
  String get ing_form_edit => 'edit ingredient';

  @override
  String get ing_form_new => 'new ingredient';

  @override
  String get ing_form_name => 'name';

  @override
  String get ing_form_name_err => 'enter a name';

  @override
  String get ing_form_stock => 'current stock';

  @override
  String get ing_form_min_stock => 'minimum stock';

  @override
  String get ing_form_unit => 'unit of measurement';

  @override
  String get ing_form_price => 'unit price';

  @override
  String get ing_form_invalid => 'invalid value';

  @override
  String get ing_form_update => 'update';

  @override
  String get ing_form_updated => 'ingredient updated';

  @override
  String get ing_form_created => 'ingredient created';

  @override
  String get ord_list_title => 'orders - ';

  @override
  String get ord_list_service => 'service';

  @override
  String get ord_list_search => 'search by order n or customer';

  @override
  String get ord_list_status => 'status';

  @override
  String get ord_list_empty => 'no orders';

  @override
  String get ord_list_new => 'new';

  @override
  String get ord_list_products => 'products';

  @override
  String get prod_form_edit => 'edit product';

  @override
  String get prod_form_new => 'new product';

  @override
  String get prod_form_change_img => 'change image';

  @override
  String get prod_form_name => 'product name';

  @override
  String get prod_form_name_err => 'enter a name';

  @override
  String get prod_form_price => 'unit price';

  @override
  String get prod_form_price_err => 'enter a price';

  @override
  String get prod_form_price_inv => 'invalid price';

  @override
  String get prod_form_cat => 'category';

  @override
  String get prod_form_desc => 'description (optional)';

  @override
  String get prod_form_allergens => 'allergens:';

  @override
  String get prod_form_update => 'update';

  @override
  String get prod_form_create => 'create product';

  @override
  String get prod_form_msg_updated => 'product updated';

  @override
  String get prod_form_msg_created => 'product created';

  @override
  String get prod_ing_title => 'ingredients of ';

  @override
  String get prod_ing_empty => 'no ingredients assigned';

  @override
  String get prod_ing_needed => 'needed: ';

  @override
  String get prod_ing_add_tooltip => 'add ingredient';

  @override
  String get prod_ing_add_title => 'add ingredient';

  @override
  String get prod_ing_ing_label => 'ingredient';

  @override
  String get prod_ing_qty_label => 'needed quantity';

  @override
  String get prod_ing_btn_cancel => 'cancel';

  @override
  String get prod_ing_btn_add => 'add';

  @override
  String get prod_ing_err_qty => 'invalid quantity';

  @override
  String get prod_ing_msg_added => 'ingredient added';

  @override
  String get prod_ing_err_min => 'error: minimum one ingredient';

  @override
  String get prod_ing_del_title => 'remove ingredient';

  @override
  String get prod_ing_del_msg => 'remove ingredient from this product?';

  @override
  String get prod_ing_btn_del => 'remove';

  @override
  String get prod_ing_msg_del => 'ingredient removed';

  @override
  String get prod_list_title => 'product management';

  @override
  String get prod_list_empty => 'no products';

  @override
  String get prod_list_stock => 'stock: ';

  @override
  String get prod_list_del_title => 'delete product';

  @override
  String get prod_list_del_msg => 'delete product?';

  @override
  String get prod_list_btn_del => 'delete';

  @override
  String get prod_list_msg_del => 'product deleted';

  @override
  String get prod_list_tooltip_new => 'new product';

  @override
  String get ord_det_confirm_title => 'confirm change';

  @override
  String get ord_det_confirm_msg => 'change status to ';

  @override
  String get ord_det_cancel => 'cancel';

  @override
  String get ord_det_confirm => 'confirm';

  @override
  String get ord_det_status_updated => 'status updated to ';

  @override
  String get ord_det_error => 'error: ';

  @override
  String get ord_det_btn_start => 'start preparation';

  @override
  String get ord_det_btn_ready => 'mark as ready';

  @override
  String get ord_det_btn_completed => 'order completed';

  @override
  String get ord_det_title => 'order #';

  @override
  String get ord_det_not_found => 'order not found';

  @override
  String get ord_det_client => 'customer: ';

  @override
  String get ord_det_order => 'order: ';

  @override
  String get ord_det_pickup => 'pickup: ';

  @override
  String get ord_det_total => 'total: €';

  @override
  String get ord_det_notes_title => 'customer notes';

  @override
  String get ord_det_products_title => 'products';

  @override
  String get ord_det_qty => 'quantity: ';
}
