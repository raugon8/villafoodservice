import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @login_titulo.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login_titulo;

  /// No description provided for @login_email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get login_email;

  /// No description provided for @login_password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get login_password;

  /// No description provided for @login_boton.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get login_boton;

  /// No description provided for @login_registro.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get login_registro;

  /// No description provided for @catalogo_titulo.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get catalogo_titulo;

  /// No description provided for @carrito_titulo.
  ///
  /// In es, this message translates to:
  /// **'Mi carrito'**
  String get carrito_titulo;

  /// No description provided for @carrito_confirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pedido'**
  String get carrito_confirmar;

  /// No description provided for @carrito_vacio.
  ///
  /// In es, this message translates to:
  /// **'Tu carrito está vacío'**
  String get carrito_vacio;

  /// No description provided for @pedidos_titulo.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get pedidos_titulo;

  /// No description provided for @error_conexion.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Inténtalo de nuevo.'**
  String get error_conexion;

  /// No description provided for @error_campos.
  ///
  /// In es, this message translates to:
  /// **'Por favor rellena todos los campos'**
  String get error_campos;

  /// No description provided for @boton_reintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get boton_reintentar;

  /// No description provided for @catalogo_buscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar producto o ingrediente...'**
  String get catalogo_buscar;

  /// No description provided for @catalogo_ordenar.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get catalogo_ordenar;

  /// No description provided for @catalogo_todas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get catalogo_todas;

  /// No description provided for @catalogo_sin_resultados.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get catalogo_sin_resultados;

  /// No description provided for @catalogo_sin_stock.
  ///
  /// In es, this message translates to:
  /// **'Sin stock'**
  String get catalogo_sin_stock;

  /// No description provided for @catalogo_uds.
  ///
  /// In es, this message translates to:
  /// **'uds'**
  String get catalogo_uds;

  /// No description provided for @catalogo_anadido.
  ///
  /// In es, this message translates to:
  /// **'añadido al carrito'**
  String get catalogo_anadido;

  /// No description provided for @sort_nombre_az.
  ///
  /// In es, this message translates to:
  /// **'Nombre A-Z'**
  String get sort_nombre_az;

  /// No description provided for @sort_nombre_za.
  ///
  /// In es, this message translates to:
  /// **'Nombre Z-A'**
  String get sort_nombre_za;

  /// No description provided for @sort_precio_asc.
  ///
  /// In es, this message translates to:
  /// **'Precio menor-mayor'**
  String get sort_precio_asc;

  /// No description provided for @sort_precio_desc.
  ///
  /// In es, this message translates to:
  /// **'Precio mayor-menor'**
  String get sort_precio_desc;

  /// No description provided for @sort_disponibles.
  ///
  /// In es, this message translates to:
  /// **'Disponibles primero'**
  String get sort_disponibles;

  /// No description provided for @sort_vendidos.
  ///
  /// In es, this message translates to:
  /// **'Más vendidos'**
  String get sort_vendidos;

  /// No description provided for @pedidos_vacio.
  ///
  /// In es, this message translates to:
  /// **'No has hecho pedidos aún'**
  String get pedidos_vacio;

  /// No description provided for @pedidos_numero.
  ///
  /// In es, this message translates to:
  /// **'Pedido #'**
  String get pedidos_numero;

  /// No description provided for @pedidos_estado.
  ///
  /// In es, this message translates to:
  /// **'Estado:'**
  String get pedidos_estado;

  /// No description provided for @pedidos_total.
  ///
  /// In es, this message translates to:
  /// **'Total:'**
  String get pedidos_total;

  /// No description provided for @home_sesion_como.
  ///
  /// In es, this message translates to:
  /// **'Sesión como: '**
  String get home_sesion_como;

  /// No description provided for @home_rol_admin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get home_rol_admin;

  /// No description provided for @home_rol_cliente.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get home_rol_cliente;

  /// No description provided for @home_rol_dependiente.
  ///
  /// In es, this message translates to:
  /// **'Dependiente'**
  String get home_rol_dependiente;

  /// No description provided for @home_rol_almacen.
  ///
  /// In es, this message translates to:
  /// **'Almacén'**
  String get home_rol_almacen;

  /// No description provided for @home_rol_sin_rol.
  ///
  /// In es, this message translates to:
  /// **'Sin rol'**
  String get home_rol_sin_rol;

  /// No description provided for @home_cambiar_rol.
  ///
  /// In es, this message translates to:
  /// **'Cambiar rol'**
  String get home_cambiar_rol;

  /// No description provided for @home_cerrar_sesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get home_cerrar_sesion;

  /// No description provided for @home_btn_dashboard.
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get home_btn_dashboard;

  /// No description provided for @home_desc_dashboard.
  ///
  /// In es, this message translates to:
  /// **'Ver estadísticas generales'**
  String get home_desc_dashboard;

  /// No description provided for @home_btn_usuarios.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get home_btn_usuarios;

  /// No description provided for @home_desc_usuarios.
  ///
  /// In es, this message translates to:
  /// **'Gestionar cuentas de usuario'**
  String get home_desc_usuarios;

  /// No description provided for @home_btn_categorias.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get home_btn_categorias;

  /// No description provided for @home_desc_categorias.
  ///
  /// In es, this message translates to:
  /// **'Gestionar categorías de productos'**
  String get home_desc_categorias;

  /// No description provided for @home_btn_ingredientes.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes'**
  String get home_btn_ingredientes;

  /// No description provided for @home_desc_ingredientes.
  ///
  /// In es, this message translates to:
  /// **'Gestionar existencias de ingredientes'**
  String get home_desc_ingredientes;

  /// No description provided for @home_btn_productos.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get home_btn_productos;

  /// No description provided for @home_desc_productos.
  ///
  /// In es, this message translates to:
  /// **'Gestionar catálogo de productos'**
  String get home_desc_productos;

  /// No description provided for @home_btn_catalogo.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get home_btn_catalogo;

  /// No description provided for @home_desc_catalogo.
  ///
  /// In es, this message translates to:
  /// **'Buscar y filtrar productos'**
  String get home_desc_catalogo;

  /// No description provided for @home_btn_carrito.
  ///
  /// In es, this message translates to:
  /// **'Carrito'**
  String get home_btn_carrito;

  /// No description provided for @home_desc_carrito.
  ///
  /// In es, this message translates to:
  /// **'Ver productos seleccionados para comprar'**
  String get home_desc_carrito;

  /// No description provided for @home_btn_pedidos.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get home_btn_pedidos;

  /// No description provided for @home_desc_pedidos.
  ///
  /// In es, this message translates to:
  /// **'Ver historial de compras realizadas'**
  String get home_desc_pedidos;

  /// No description provided for @home_btn_staff.
  ///
  /// In es, this message translates to:
  /// **'Gestión Staff'**
  String get home_btn_staff;

  /// No description provided for @home_desc_staff.
  ///
  /// In es, this message translates to:
  /// **'Panel de preparación de pedidos'**
  String get home_desc_staff;

  /// No description provided for @reg_faltan_datos.
  ///
  /// In es, this message translates to:
  /// **'Faltan datos'**
  String get reg_faltan_datos;

  /// No description provided for @reg_creado.
  ///
  /// In es, this message translates to:
  /// **'Creado: '**
  String get reg_creado;

  /// No description provided for @reg_titulo.
  ///
  /// In es, this message translates to:
  /// **'Registro'**
  String get reg_titulo;

  /// No description provided for @reg_nombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get reg_nombre;

  /// No description provided for @reg_email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get reg_email;

  /// No description provided for @reg_pass.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get reg_pass;

  /// No description provided for @reg_crear.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get reg_crear;

  /// No description provided for @reg_atras.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get reg_atras;

  /// No description provided for @cart_confirmado_tit.
  ///
  /// In es, this message translates to:
  /// **'¡Pedido confirmado!'**
  String get cart_confirmado_tit;

  /// No description provided for @cart_aceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get cart_aceptar;

  /// No description provided for @cart_vaciar.
  ///
  /// In es, this message translates to:
  /// **'Vaciar'**
  String get cart_vaciar;

  /// No description provided for @cart_ud.
  ///
  /// In es, this message translates to:
  /// **'/ ud'**
  String get cart_ud;

  /// No description provided for @cart_notas.
  ///
  /// In es, this message translates to:
  /// **'Notas del pedido (opcional)'**
  String get cart_notas;

  /// No description provided for @cart_productos_count.
  ///
  /// In es, this message translates to:
  /// **'productos'**
  String get cart_productos_count;

  /// No description provided for @det_alergenos_tit.
  ///
  /// In es, this message translates to:
  /// **'Alérgenos declarados:'**
  String get det_alergenos_tit;

  /// No description provided for @det_sin_alergenos.
  ///
  /// In es, this message translates to:
  /// **'Sin alérgenos declarados'**
  String get det_sin_alergenos;

  /// No description provided for @det_add_carrito.
  ///
  /// In es, this message translates to:
  /// **'Añadir al carrito'**
  String get det_add_carrito;

  /// No description provided for @det_agotado.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get det_agotado;

  /// No description provided for @role_selector_title.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu rol'**
  String get role_selector_title;

  /// No description provided for @dash_title.
  ///
  /// In es, this message translates to:
  /// **'Panel Administrativo'**
  String get dash_title;

  /// No description provided for @dash_tooltip_users.
  ///
  /// In es, this message translates to:
  /// **'Gestionar usuarios'**
  String get dash_tooltip_users;

  /// No description provided for @dash_period_label.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get dash_period_label;

  /// No description provided for @dash_period_all.
  ///
  /// In es, this message translates to:
  /// **'Todo el historial'**
  String get dash_period_all;

  /// No description provided for @dash_period_today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get dash_period_today;

  /// No description provided for @dash_period_week.
  ///
  /// In es, this message translates to:
  /// **'Última semana'**
  String get dash_period_week;

  /// No description provided for @dash_period_month.
  ///
  /// In es, this message translates to:
  /// **'Último mes'**
  String get dash_period_month;

  /// No description provided for @dash_period_6months.
  ///
  /// In es, this message translates to:
  /// **'Últimos 6 meses'**
  String get dash_period_6months;

  /// No description provided for @dash_period_custom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get dash_period_custom;

  /// No description provided for @dash_date_start.
  ///
  /// In es, this message translates to:
  /// **'Fecha inicio'**
  String get dash_date_start;

  /// No description provided for @dash_date_end.
  ///
  /// In es, this message translates to:
  /// **'Fecha fin'**
  String get dash_date_end;

  /// No description provided for @dash_del.
  ///
  /// In es, this message translates to:
  /// **'Del '**
  String get dash_del;

  /// No description provided for @dash_al.
  ///
  /// In es, this message translates to:
  /// **' al '**
  String get dash_al;

  /// No description provided for @dash_sec_pedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get dash_sec_pedidos;

  /// No description provided for @dash_card_total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get dash_card_total;

  /// No description provided for @dash_card_pendientes.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get dash_card_pendientes;

  /// No description provided for @dash_card_preparacion.
  ///
  /// In es, this message translates to:
  /// **'En preparación'**
  String get dash_card_preparacion;

  /// No description provided for @dash_card_listos.
  ///
  /// In es, this message translates to:
  /// **'Listos'**
  String get dash_card_listos;

  /// No description provided for @dash_card_entregados.
  ///
  /// In es, this message translates to:
  /// **'Entregados'**
  String get dash_card_entregados;

  /// No description provided for @dash_card_cancelados.
  ///
  /// In es, this message translates to:
  /// **'Cancelados'**
  String get dash_card_cancelados;

  /// No description provided for @dash_sec_ventas.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get dash_sec_ventas;

  /// No description provided for @dash_card_ingresos.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get dash_card_ingresos;

  /// No description provided for @dash_card_completados.
  ///
  /// In es, this message translates to:
  /// **'Completados'**
  String get dash_card_completados;

  /// No description provided for @dash_card_ticket.
  ///
  /// In es, this message translates to:
  /// **'Ticket medio'**
  String get dash_card_ticket;

  /// No description provided for @dash_sec_productos.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get dash_sec_productos;

  /// No description provided for @dash_card_activos.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get dash_card_activos;

  /// No description provided for @dash_card_sinstock.
  ///
  /// In es, this message translates to:
  /// **'Sin stock'**
  String get dash_card_sinstock;

  /// No description provided for @dash_card_desactivados.
  ///
  /// In es, this message translates to:
  /// **'Desactivados'**
  String get dash_card_desactivados;

  /// No description provided for @dash_card_vendidos.
  ///
  /// In es, this message translates to:
  /// **' vendidos'**
  String get dash_card_vendidos;

  /// No description provided for @dash_sec_ingredientes.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes'**
  String get dash_sec_ingredientes;

  /// No description provided for @dash_card_stockcritico.
  ///
  /// In es, this message translates to:
  /// **'Stock crítico'**
  String get dash_card_stockcritico;

  /// No description provided for @dash_card_stockbajo.
  ///
  /// In es, this message translates to:
  /// **'Stock bajo'**
  String get dash_card_stockbajo;

  /// No description provided for @dash_sec_usuarios.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get dash_sec_usuarios;

  /// No description provided for @dash_card_admins.
  ///
  /// In es, this message translates to:
  /// **'Admins'**
  String get dash_card_admins;

  /// No description provided for @dash_card_clientes.
  ///
  /// In es, this message translates to:
  /// **'Clientes'**
  String get dash_card_clientes;

  /// No description provided for @dash_card_dependientes.
  ///
  /// In es, this message translates to:
  /// **'Dependientes'**
  String get dash_card_dependientes;

  /// No description provided for @dash_card_almacen.
  ///
  /// In es, this message translates to:
  /// **'Almacén'**
  String get dash_card_almacen;

  /// No description provided for @dash_stat_all.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de todo el historial'**
  String get dash_stat_all;

  /// No description provided for @dash_stat_del.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas del '**
  String get dash_stat_del;

  /// No description provided for @user_mgr_title.
  ///
  /// In es, this message translates to:
  /// **'Gestión de usuarios'**
  String get user_mgr_title;

  /// No description provided for @user_mgr_create_title.
  ///
  /// In es, this message translates to:
  /// **'Crear usuario'**
  String get user_mgr_create_title;

  /// No description provided for @user_mgr_edit_title.
  ///
  /// In es, this message translates to:
  /// **'Editar usuario'**
  String get user_mgr_edit_title;

  /// No description provided for @user_mgr_name.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get user_mgr_name;

  /// No description provided for @user_mgr_email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get user_mgr_email;

  /// No description provided for @user_mgr_pass.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get user_mgr_pass;

  /// No description provided for @user_mgr_new_pass.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña (opcional)'**
  String get user_mgr_new_pass;

  /// No description provided for @user_mgr_roles.
  ///
  /// In es, this message translates to:
  /// **'Roles:'**
  String get user_mgr_roles;

  /// No description provided for @user_mgr_cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get user_mgr_cancel;

  /// No description provided for @user_mgr_create_btn.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get user_mgr_create_btn;

  /// No description provided for @user_mgr_save_btn.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get user_mgr_save_btn;

  /// No description provided for @user_mgr_err_name_email.
  ///
  /// In es, this message translates to:
  /// **'Nombre y email son obligatorios'**
  String get user_mgr_err_name_email;

  /// No description provided for @user_mgr_err_roles.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un rol'**
  String get user_mgr_err_roles;

  /// No description provided for @user_mgr_err_pass.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get user_mgr_err_pass;

  /// No description provided for @user_mgr_msg_created.
  ///
  /// In es, this message translates to:
  /// **'Usuario creado correctamente'**
  String get user_mgr_msg_created;

  /// No description provided for @user_mgr_msg_updated.
  ///
  /// In es, this message translates to:
  /// **'Usuario actualizado correctamente'**
  String get user_mgr_msg_updated;

  /// No description provided for @cat_title.
  ///
  /// In es, this message translates to:
  /// **'gestion de categorias'**
  String get cat_title;

  /// No description provided for @cat_new.
  ///
  /// In es, this message translates to:
  /// **'nueva categoria'**
  String get cat_new;

  /// No description provided for @cat_edit.
  ///
  /// In es, this message translates to:
  /// **'editar categoria'**
  String get cat_edit;

  /// No description provided for @cat_name.
  ///
  /// In es, this message translates to:
  /// **'nombre *'**
  String get cat_name;

  /// No description provided for @cat_desc.
  ///
  /// In es, this message translates to:
  /// **'descripcion'**
  String get cat_desc;

  /// No description provided for @cat_cancel.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get cat_cancel;

  /// No description provided for @cat_save.
  ///
  /// In es, this message translates to:
  /// **'guardar'**
  String get cat_save;

  /// No description provided for @cat_empty.
  ///
  /// In es, this message translates to:
  /// **'no hay categorias'**
  String get cat_empty;

  /// No description provided for @ing_list_title.
  ///
  /// In es, this message translates to:
  /// **'gestion de ingredientes'**
  String get ing_list_title;

  /// No description provided for @ing_list_empty.
  ///
  /// In es, this message translates to:
  /// **'no hay ingredientes'**
  String get ing_list_empty;

  /// No description provided for @ing_list_stock.
  ///
  /// In es, this message translates to:
  /// **'stock: '**
  String get ing_list_stock;

  /// No description provided for @ing_list_weight.
  ///
  /// In es, this message translates to:
  /// **'pesaje en: '**
  String get ing_list_weight;

  /// No description provided for @ing_list_delete_title.
  ///
  /// In es, this message translates to:
  /// **'eliminar ingrediente'**
  String get ing_list_delete_title;

  /// No description provided for @ing_list_delete_msg.
  ///
  /// In es, this message translates to:
  /// **'eliminar'**
  String get ing_list_delete_msg;

  /// No description provided for @ing_list_deleted.
  ///
  /// In es, this message translates to:
  /// **'ingrediente eliminado'**
  String get ing_list_deleted;

  /// No description provided for @ing_form_edit.
  ///
  /// In es, this message translates to:
  /// **'editar ingrediente'**
  String get ing_form_edit;

  /// No description provided for @ing_form_new.
  ///
  /// In es, this message translates to:
  /// **'nuevo ingrediente'**
  String get ing_form_new;

  /// No description provided for @ing_form_name.
  ///
  /// In es, this message translates to:
  /// **'nombre'**
  String get ing_form_name;

  /// No description provided for @ing_form_name_err.
  ///
  /// In es, this message translates to:
  /// **'ingresa un nombre'**
  String get ing_form_name_err;

  /// No description provided for @ing_form_stock.
  ///
  /// In es, this message translates to:
  /// **'stock actual'**
  String get ing_form_stock;

  /// No description provided for @ing_form_min_stock.
  ///
  /// In es, this message translates to:
  /// **'stock minimo'**
  String get ing_form_min_stock;

  /// No description provided for @ing_form_unit.
  ///
  /// In es, this message translates to:
  /// **'unidad de medida'**
  String get ing_form_unit;

  /// No description provided for @ing_form_price.
  ///
  /// In es, this message translates to:
  /// **'precio unitario'**
  String get ing_form_price;

  /// No description provided for @ing_form_invalid.
  ///
  /// In es, this message translates to:
  /// **'valor invalido'**
  String get ing_form_invalid;

  /// No description provided for @ing_form_update.
  ///
  /// In es, this message translates to:
  /// **'actualizar'**
  String get ing_form_update;

  /// No description provided for @ing_form_updated.
  ///
  /// In es, this message translates to:
  /// **'ingrediente actualizado'**
  String get ing_form_updated;

  /// No description provided for @ing_form_created.
  ///
  /// In es, this message translates to:
  /// **'ingrediente creado'**
  String get ing_form_created;

  /// No description provided for @ord_list_title.
  ///
  /// In es, this message translates to:
  /// **'pedidos - '**
  String get ord_list_title;

  /// No description provided for @ord_list_service.
  ///
  /// In es, this message translates to:
  /// **'servicio'**
  String get ord_list_service;

  /// No description provided for @ord_list_search.
  ///
  /// In es, this message translates to:
  /// **'buscar por n pedido o cliente'**
  String get ord_list_search;

  /// No description provided for @ord_list_status.
  ///
  /// In es, this message translates to:
  /// **'estado'**
  String get ord_list_status;

  /// No description provided for @ord_list_empty.
  ///
  /// In es, this message translates to:
  /// **'no hay pedidos'**
  String get ord_list_empty;

  /// No description provided for @ord_list_new.
  ///
  /// In es, this message translates to:
  /// **'nuevo'**
  String get ord_list_new;

  /// No description provided for @ord_list_products.
  ///
  /// In es, this message translates to:
  /// **'productos'**
  String get ord_list_products;

  /// No description provided for @prod_form_edit.
  ///
  /// In es, this message translates to:
  /// **'editar producto'**
  String get prod_form_edit;

  /// No description provided for @prod_form_new.
  ///
  /// In es, this message translates to:
  /// **'nuevo producto'**
  String get prod_form_new;

  /// No description provided for @prod_form_change_img.
  ///
  /// In es, this message translates to:
  /// **'cambiar imagen'**
  String get prod_form_change_img;

  /// No description provided for @prod_form_name.
  ///
  /// In es, this message translates to:
  /// **'nombre del producto'**
  String get prod_form_name;

  /// No description provided for @prod_form_name_err.
  ///
  /// In es, this message translates to:
  /// **'ingresa un nombre'**
  String get prod_form_name_err;

  /// No description provided for @prod_form_price.
  ///
  /// In es, this message translates to:
  /// **'precio unitario'**
  String get prod_form_price;

  /// No description provided for @prod_form_price_err.
  ///
  /// In es, this message translates to:
  /// **'ingresa un precio'**
  String get prod_form_price_err;

  /// No description provided for @prod_form_price_inv.
  ///
  /// In es, this message translates to:
  /// **'precio invalido'**
  String get prod_form_price_inv;

  /// No description provided for @prod_form_cat.
  ///
  /// In es, this message translates to:
  /// **'categoria'**
  String get prod_form_cat;

  /// No description provided for @prod_form_desc.
  ///
  /// In es, this message translates to:
  /// **'descripcion (opcional)'**
  String get prod_form_desc;

  /// No description provided for @prod_form_allergens.
  ///
  /// In es, this message translates to:
  /// **'alergenos:'**
  String get prod_form_allergens;

  /// No description provided for @prod_form_update.
  ///
  /// In es, this message translates to:
  /// **'actualizar'**
  String get prod_form_update;

  /// No description provided for @prod_form_create.
  ///
  /// In es, this message translates to:
  /// **'crear producto'**
  String get prod_form_create;

  /// No description provided for @prod_form_msg_updated.
  ///
  /// In es, this message translates to:
  /// **'producto actualizado'**
  String get prod_form_msg_updated;

  /// No description provided for @prod_form_msg_created.
  ///
  /// In es, this message translates to:
  /// **'producto creado'**
  String get prod_form_msg_created;

  /// No description provided for @prod_ing_title.
  ///
  /// In es, this message translates to:
  /// **'ingredientes de '**
  String get prod_ing_title;

  /// No description provided for @prod_ing_empty.
  ///
  /// In es, this message translates to:
  /// **'sin ingredientes asignados'**
  String get prod_ing_empty;

  /// No description provided for @prod_ing_needed.
  ///
  /// In es, this message translates to:
  /// **'necesario: '**
  String get prod_ing_needed;

  /// No description provided for @prod_ing_add_tooltip.
  ///
  /// In es, this message translates to:
  /// **'agregar ingrediente'**
  String get prod_ing_add_tooltip;

  /// No description provided for @prod_ing_add_title.
  ///
  /// In es, this message translates to:
  /// **'agregar ingrediente'**
  String get prod_ing_add_title;

  /// No description provided for @prod_ing_ing_label.
  ///
  /// In es, this message translates to:
  /// **'ingrediente'**
  String get prod_ing_ing_label;

  /// No description provided for @prod_ing_qty_label.
  ///
  /// In es, this message translates to:
  /// **'cantidad necesaria'**
  String get prod_ing_qty_label;

  /// No description provided for @prod_ing_btn_cancel.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get prod_ing_btn_cancel;

  /// No description provided for @prod_ing_btn_add.
  ///
  /// In es, this message translates to:
  /// **'agregar'**
  String get prod_ing_btn_add;

  /// No description provided for @prod_ing_err_qty.
  ///
  /// In es, this message translates to:
  /// **'cantidad invalida'**
  String get prod_ing_err_qty;

  /// No description provided for @prod_ing_msg_added.
  ///
  /// In es, this message translates to:
  /// **'ingrediente agregado'**
  String get prod_ing_msg_added;

  /// No description provided for @prod_ing_err_min.
  ///
  /// In es, this message translates to:
  /// **'error: minimo un ingrediente'**
  String get prod_ing_err_min;

  /// No description provided for @prod_ing_del_title.
  ///
  /// In es, this message translates to:
  /// **'quitar ingrediente'**
  String get prod_ing_del_title;

  /// No description provided for @prod_ing_del_msg.
  ///
  /// In es, this message translates to:
  /// **'¿quitar ingrediente de este producto?'**
  String get prod_ing_del_msg;

  /// No description provided for @prod_ing_btn_del.
  ///
  /// In es, this message translates to:
  /// **'quitar'**
  String get prod_ing_btn_del;

  /// No description provided for @prod_ing_msg_del.
  ///
  /// In es, this message translates to:
  /// **'ingrediente quitado'**
  String get prod_ing_msg_del;

  /// No description provided for @prod_list_title.
  ///
  /// In es, this message translates to:
  /// **'gestion de productos'**
  String get prod_list_title;

  /// No description provided for @prod_list_empty.
  ///
  /// In es, this message translates to:
  /// **'no hay productos'**
  String get prod_list_empty;

  /// No description provided for @prod_list_stock.
  ///
  /// In es, this message translates to:
  /// **'stock: '**
  String get prod_list_stock;

  /// No description provided for @prod_list_del_title.
  ///
  /// In es, this message translates to:
  /// **'eliminar producto'**
  String get prod_list_del_title;

  /// No description provided for @prod_list_del_msg.
  ///
  /// In es, this message translates to:
  /// **'¿eliminar producto?'**
  String get prod_list_del_msg;

  /// No description provided for @prod_list_btn_del.
  ///
  /// In es, this message translates to:
  /// **'eliminar'**
  String get prod_list_btn_del;

  /// No description provided for @prod_list_msg_del.
  ///
  /// In es, this message translates to:
  /// **'producto eliminado'**
  String get prod_list_msg_del;

  /// No description provided for @prod_list_tooltip_new.
  ///
  /// In es, this message translates to:
  /// **'nuevo producto'**
  String get prod_list_tooltip_new;

  /// No description provided for @ord_det_confirm_title.
  ///
  /// In es, this message translates to:
  /// **'confirmar cambio'**
  String get ord_det_confirm_title;

  /// No description provided for @ord_det_confirm_msg.
  ///
  /// In es, this message translates to:
  /// **'¿cambiar estado a '**
  String get ord_det_confirm_msg;

  /// No description provided for @ord_det_cancel.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get ord_det_cancel;

  /// No description provided for @ord_det_confirm.
  ///
  /// In es, this message translates to:
  /// **'confirmar'**
  String get ord_det_confirm;

  /// No description provided for @ord_det_status_updated.
  ///
  /// In es, this message translates to:
  /// **'estado actualizado a '**
  String get ord_det_status_updated;

  /// No description provided for @ord_det_error.
  ///
  /// In es, this message translates to:
  /// **'error: '**
  String get ord_det_error;

  /// No description provided for @ord_det_btn_start.
  ///
  /// In es, this message translates to:
  /// **'iniciar preparacion'**
  String get ord_det_btn_start;

  /// No description provided for @ord_det_btn_ready.
  ///
  /// In es, this message translates to:
  /// **'marcar como listo'**
  String get ord_det_btn_ready;

  /// No description provided for @ord_det_btn_completed.
  ///
  /// In es, this message translates to:
  /// **'pedido completado'**
  String get ord_det_btn_completed;

  /// No description provided for @ord_det_title.
  ///
  /// In es, this message translates to:
  /// **'pedido #'**
  String get ord_det_title;

  /// No description provided for @ord_det_not_found.
  ///
  /// In es, this message translates to:
  /// **'pedido no encontrado'**
  String get ord_det_not_found;

  /// No description provided for @ord_det_client.
  ///
  /// In es, this message translates to:
  /// **'cliente: '**
  String get ord_det_client;

  /// No description provided for @ord_det_order.
  ///
  /// In es, this message translates to:
  /// **'pedido: '**
  String get ord_det_order;

  /// No description provided for @ord_det_pickup.
  ///
  /// In es, this message translates to:
  /// **'recogida: '**
  String get ord_det_pickup;

  /// No description provided for @ord_det_total.
  ///
  /// In es, this message translates to:
  /// **'total: €'**
  String get ord_det_total;

  /// No description provided for @ord_det_notes_title.
  ///
  /// In es, this message translates to:
  /// **'notas del cliente'**
  String get ord_det_notes_title;

  /// No description provided for @ord_det_products_title.
  ///
  /// In es, this message translates to:
  /// **'productos'**
  String get ord_det_products_title;

  /// No description provided for @ord_det_qty.
  ///
  /// In es, this message translates to:
  /// **'cantidad: '**
  String get ord_det_qty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
