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
