// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get login_titulo => 'Iniciar sesión';

  @override
  String get login_email => 'Correo electrónico';

  @override
  String get login_password => 'Contraseña';

  @override
  String get login_boton => 'Entrar';

  @override
  String get login_registro => '¿No tienes cuenta? Regístrate';

  @override
  String get catalogo_titulo => 'Catálogo';

  @override
  String get carrito_titulo => 'Mi carrito';

  @override
  String get carrito_confirmar => 'Confirmar pedido';

  @override
  String get carrito_vacio => 'Tu carrito está vacío';

  @override
  String get pedidos_titulo => 'Mis pedidos';

  @override
  String get error_conexion => 'Error de conexión. Inténtalo de nuevo.';

  @override
  String get error_campos => 'Por favor rellena todos los campos';

  @override
  String get boton_reintentar => 'Reintentar';

  @override
  String get catalogo_buscar => 'Buscar producto o ingrediente...';

  @override
  String get catalogo_ordenar => 'Ordenar';

  @override
  String get catalogo_todas => 'Todas';

  @override
  String get catalogo_sin_resultados => 'Sin resultados';

  @override
  String get catalogo_sin_stock => 'Sin stock';

  @override
  String get catalogo_uds => 'uds';

  @override
  String get catalogo_anadido => 'añadido al carrito';

  @override
  String get sort_nombre_az => 'Nombre A-Z';

  @override
  String get sort_nombre_za => 'Nombre Z-A';

  @override
  String get sort_precio_asc => 'Precio menor-mayor';

  @override
  String get sort_precio_desc => 'Precio mayor-menor';

  @override
  String get sort_disponibles => 'Disponibles primero';

  @override
  String get sort_vendidos => 'Más vendidos';

  @override
  String get pedidos_vacio => 'No has hecho pedidos aún';

  @override
  String get pedidos_numero => 'Pedido #';

  @override
  String get pedidos_estado => 'Estado:';

  @override
  String get pedidos_total => 'Total:';

  @override
  String get home_sesion_como => 'Sesión como: ';

  @override
  String get home_rol_admin => 'Administrador';

  @override
  String get home_rol_cliente => 'Cliente';

  @override
  String get home_rol_dependiente => 'Dependiente';

  @override
  String get home_rol_almacen => 'Almacén';

  @override
  String get home_rol_sin_rol => 'Sin rol';

  @override
  String get home_cambiar_rol => 'Cambiar rol';

  @override
  String get home_cerrar_sesion => 'Cerrar sesión';

  @override
  String get home_btn_dashboard => 'Dashboard';

  @override
  String get home_desc_dashboard => 'Ver estadísticas generales';

  @override
  String get home_btn_usuarios => 'Usuarios';

  @override
  String get home_desc_usuarios => 'Gestionar cuentas de usuario';

  @override
  String get home_btn_categorias => 'Categorías';

  @override
  String get home_desc_categorias => 'Gestionar categorías de productos';

  @override
  String get home_btn_ingredientes => 'Ingredientes';

  @override
  String get home_desc_ingredientes => 'Gestionar existencias de ingredientes';

  @override
  String get home_btn_productos => 'Productos';

  @override
  String get home_desc_productos => 'Gestionar catálogo de productos';

  @override
  String get home_btn_catalogo => 'Catálogo';

  @override
  String get home_desc_catalogo => 'Buscar y filtrar productos';

  @override
  String get home_btn_carrito => 'Carrito';

  @override
  String get home_desc_carrito => 'Ver productos seleccionados para comprar';

  @override
  String get home_btn_pedidos => 'Mis pedidos';

  @override
  String get home_desc_pedidos => 'Ver historial de compras realizadas';

  @override
  String get home_btn_staff => 'Gestión Staff';

  @override
  String get home_desc_staff => 'Panel de preparación de pedidos';

  @override
  String get reg_faltan_datos => 'Faltan datos';

  @override
  String get reg_creado => 'Creado: ';

  @override
  String get reg_titulo => 'Registro';

  @override
  String get reg_nombre => 'Nombre';

  @override
  String get reg_email => 'Email';

  @override
  String get reg_pass => 'Contraseña';

  @override
  String get reg_crear => 'Crear';

  @override
  String get reg_atras => 'Atrás';

  @override
  String get cart_confirmado_tit => '¡Pedido confirmado!';

  @override
  String get cart_aceptar => 'Aceptar';

  @override
  String get cart_vaciar => 'Vaciar';

  @override
  String get cart_ud => '/ ud';

  @override
  String get cart_notas => 'Notas del pedido (opcional)';

  @override
  String get cart_productos_count => 'productos';

  @override
  String get det_alergenos_tit => 'Alérgenos declarados:';

  @override
  String get det_sin_alergenos => 'Sin alérgenos declarados';

  @override
  String get det_add_carrito => 'Añadir al carrito';

  @override
  String get det_agotado => 'Agotado';

  @override
  String get role_selector_title => 'Selecciona tu rol';

  @override
  String get dash_title => 'Panel Administrativo';

  @override
  String get dash_tooltip_users => 'Gestionar usuarios';

  @override
  String get dash_period_label => 'Periodo';

  @override
  String get dash_period_all => 'Todo el historial';

  @override
  String get dash_period_today => 'Hoy';

  @override
  String get dash_period_week => 'Última semana';

  @override
  String get dash_period_month => 'Último mes';

  @override
  String get dash_period_6months => 'Últimos 6 meses';

  @override
  String get dash_period_custom => 'Personalizado';

  @override
  String get dash_date_start => 'Fecha inicio';

  @override
  String get dash_date_end => 'Fecha fin';

  @override
  String get dash_del => 'Del ';

  @override
  String get dash_al => ' al ';

  @override
  String get dash_sec_pedidos => 'Pedidos';

  @override
  String get dash_card_total => 'Total';

  @override
  String get dash_card_pendientes => 'Pendientes';

  @override
  String get dash_card_preparacion => 'En preparación';

  @override
  String get dash_card_listos => 'Listos';

  @override
  String get dash_card_entregados => 'Entregados';

  @override
  String get dash_card_cancelados => 'Cancelados';

  @override
  String get dash_sec_ventas => 'Ventas';

  @override
  String get dash_card_ingresos => 'Ingresos';

  @override
  String get dash_card_completados => 'Completados';

  @override
  String get dash_card_ticket => 'Ticket medio';

  @override
  String get dash_sec_productos => 'Productos';

  @override
  String get dash_card_activos => 'Activos';

  @override
  String get dash_card_sinstock => 'Sin stock';

  @override
  String get dash_card_desactivados => 'Desactivados';

  @override
  String get dash_card_vendidos => ' vendidos';

  @override
  String get dash_sec_ingredientes => 'Ingredientes';

  @override
  String get dash_card_stockcritico => 'Stock crítico';

  @override
  String get dash_card_stockbajo => 'Stock bajo';

  @override
  String get dash_sec_usuarios => 'Usuarios';

  @override
  String get dash_card_admins => 'Admins';

  @override
  String get dash_card_clientes => 'Clientes';

  @override
  String get dash_card_dependientes => 'Dependientes';

  @override
  String get dash_card_almacen => 'Almacén';

  @override
  String get dash_stat_all => 'Estadísticas de todo el historial';

  @override
  String get dash_stat_del => 'Estadísticas del ';

  @override
  String get user_mgr_title => 'Gestión de usuarios';

  @override
  String get user_mgr_create_title => 'Crear usuario';

  @override
  String get user_mgr_edit_title => 'Editar usuario';

  @override
  String get user_mgr_name => 'Nombre completo';

  @override
  String get user_mgr_email => 'Email';

  @override
  String get user_mgr_pass => 'Contraseña';

  @override
  String get user_mgr_new_pass => 'Nueva contraseña (opcional)';

  @override
  String get user_mgr_roles => 'Roles:';

  @override
  String get user_mgr_cancel => 'Cancelar';

  @override
  String get user_mgr_create_btn => 'Crear';

  @override
  String get user_mgr_save_btn => 'Guardar';

  @override
  String get user_mgr_err_name_email => 'Nombre y email son obligatorios';

  @override
  String get user_mgr_err_roles => 'Selecciona al menos un rol';

  @override
  String get user_mgr_err_pass => 'La contraseña es obligatoria';

  @override
  String get user_mgr_msg_created => 'Usuario creado correctamente';

  @override
  String get user_mgr_msg_updated => 'Usuario actualizado correctamente';

  @override
  String get cat_title => 'gestion de categorias';

  @override
  String get cat_new => 'nueva categoria';

  @override
  String get cat_edit => 'editar categoria';

  @override
  String get cat_name => 'nombre *';

  @override
  String get cat_desc => 'descripcion';

  @override
  String get cat_cancel => 'cancelar';

  @override
  String get cat_save => 'guardar';

  @override
  String get cat_empty => 'no hay categorias';

  @override
  String get ing_list_title => 'gestion de ingredientes';

  @override
  String get ing_list_empty => 'no hay ingredientes';

  @override
  String get ing_list_stock => 'stock: ';

  @override
  String get ing_list_weight => 'pesaje en: ';

  @override
  String get ing_list_delete_title => 'eliminar ingrediente';

  @override
  String get ing_list_delete_msg => 'eliminar';

  @override
  String get ing_list_deleted => 'ingrediente eliminado';

  @override
  String get ing_form_edit => 'editar ingrediente';

  @override
  String get ing_form_new => 'nuevo ingrediente';

  @override
  String get ing_form_name => 'nombre';

  @override
  String get ing_form_name_err => 'ingresa un nombre';

  @override
  String get ing_form_stock => 'stock actual';

  @override
  String get ing_form_min_stock => 'stock minimo';

  @override
  String get ing_form_unit => 'unidad de medida';

  @override
  String get ing_form_price => 'precio unitario';

  @override
  String get ing_form_invalid => 'valor invalido';

  @override
  String get ing_form_update => 'actualizar';

  @override
  String get ing_form_updated => 'ingrediente actualizado';

  @override
  String get ing_form_created => 'ingrediente creado';

  @override
  String get ord_list_title => 'pedidos - ';

  @override
  String get ord_list_service => 'servicio';

  @override
  String get ord_list_search => 'buscar por n pedido o cliente';

  @override
  String get ord_list_status => 'estado';

  @override
  String get ord_list_empty => 'no hay pedidos';

  @override
  String get ord_list_new => 'nuevo';

  @override
  String get ord_list_products => 'productos';

  @override
  String get prod_form_edit => 'editar producto';

  @override
  String get prod_form_new => 'nuevo producto';

  @override
  String get prod_form_change_img => 'cambiar imagen';

  @override
  String get prod_form_name => 'nombre del producto';

  @override
  String get prod_form_name_err => 'ingresa un nombre';

  @override
  String get prod_form_price => 'precio unitario';

  @override
  String get prod_form_price_err => 'ingresa un precio';

  @override
  String get prod_form_price_inv => 'precio invalido';

  @override
  String get prod_form_cat => 'categoria';

  @override
  String get prod_form_desc => 'descripcion (opcional)';

  @override
  String get prod_form_allergens => 'alergenos:';

  @override
  String get prod_form_update => 'actualizar';

  @override
  String get prod_form_create => 'crear producto';

  @override
  String get prod_form_msg_updated => 'producto actualizado';

  @override
  String get prod_form_msg_created => 'producto creado';

  @override
  String get prod_ing_title => 'ingredientes de ';

  @override
  String get prod_ing_empty => 'sin ingredientes asignados';

  @override
  String get prod_ing_needed => 'necesario: ';

  @override
  String get prod_ing_add_tooltip => 'agregar ingrediente';

  @override
  String get prod_ing_add_title => 'agregar ingrediente';

  @override
  String get prod_ing_ing_label => 'ingrediente';

  @override
  String get prod_ing_qty_label => 'cantidad necesaria';

  @override
  String get prod_ing_btn_cancel => 'cancelar';

  @override
  String get prod_ing_btn_add => 'agregar';

  @override
  String get prod_ing_err_qty => 'cantidad invalida';

  @override
  String get prod_ing_msg_added => 'ingrediente agregado';

  @override
  String get prod_ing_err_min => 'error: minimo un ingrediente';

  @override
  String get prod_ing_del_title => 'quitar ingrediente';

  @override
  String get prod_ing_del_msg => '¿quitar ingrediente de este producto?';

  @override
  String get prod_ing_btn_del => 'quitar';

  @override
  String get prod_ing_msg_del => 'ingrediente quitado';

  @override
  String get prod_list_title => 'gestion de productos';

  @override
  String get prod_list_empty => 'no hay productos';

  @override
  String get prod_list_stock => 'stock: ';

  @override
  String get prod_list_del_title => 'eliminar producto';

  @override
  String get prod_list_del_msg => '¿eliminar producto?';

  @override
  String get prod_list_btn_del => 'eliminar';

  @override
  String get prod_list_msg_del => 'producto eliminado';

  @override
  String get prod_list_tooltip_new => 'nuevo producto';

  @override
  String get ord_det_confirm_title => 'confirmar cambio';

  @override
  String get ord_det_confirm_msg => '¿cambiar estado a ';

  @override
  String get ord_det_cancel => 'cancelar';

  @override
  String get ord_det_confirm => 'confirmar';

  @override
  String get ord_det_status_updated => 'estado actualizado a ';

  @override
  String get ord_det_error => 'error: ';

  @override
  String get ord_det_btn_start => 'iniciar preparacion';

  @override
  String get ord_det_btn_ready => 'marcar como listo';

  @override
  String get ord_det_btn_completed => 'pedido completado';

  @override
  String get ord_det_title => 'pedido #';

  @override
  String get ord_det_not_found => 'pedido no encontrado';

  @override
  String get ord_det_client => 'cliente: ';

  @override
  String get ord_det_order => 'pedido: ';

  @override
  String get ord_det_pickup => 'recogida: ';

  @override
  String get ord_det_total => 'total: €';

  @override
  String get ord_det_notes_title => 'notas del cliente';

  @override
  String get ord_det_products_title => 'productos';

  @override
  String get ord_det_qty => 'cantidad: ';
}
