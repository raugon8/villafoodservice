/// estadisticas de los pedidos para el panel principal
///
/// args:
///   total_pedidos (int): cantidad historica o filtrada
///   pedidos_pendientes (int): en cola
///   pedidos_en_preparacion (int): cocinandose
///   pedidos_listos (int): esperando recogida
///   pedidos_entregados (int): completados
///   pedidos_cancelados (int): anulados
class PedidosStats {
  final int total_pedidos;
  final int pedidos_pendientes;
  final int pedidos_en_preparacion;
  final int pedidos_listos;
  final int pedidos_entregados;
  final int pedidos_cancelados;

  PedidosStats({required this.total_pedidos, required this.pedidos_pendientes, required this.pedidos_en_preparacion, required this.pedidos_listos, required this.pedidos_entregados, required this.pedidos_cancelados});

  factory PedidosStats.from_json(Map<String, dynamic> json) => PedidosStats(
    total_pedidos: json['total_pedidos'] ?? 0,
    pedidos_pendientes: json['pedidos_pendientes'] ?? 0,
    pedidos_en_preparacion: json['pedidos_en_preparacion'] ?? 0,
    pedidos_listos: json['pedidos_listos'] ?? 0,
    pedidos_entregados: json['pedidos_entregados'] ?? 0,
    pedidos_cancelados: json['pedidos_cancelados'] ?? 0,
  );
}

/// metricas de rendimiento de productos y stock
///
/// args:
///   total_productos_activos (int): productos en catalogo
///   productos_sin_stock (int): productos agotados
///   productos_desactivados (int): ocultos del catalogo
///   producto_mas_vendido_nombre (String): nombre del top ventas
///   producto_mas_vendido_cantidad (int): cantidad vendida del top
class ProductosStats {
  final int total_productos_activos;
  final int productos_sin_stock;
  final int productos_desactivados;
  final String producto_mas_vendido_nombre;
  final int producto_mas_vendido_cantidad;

  ProductosStats({required this.total_productos_activos, required this.productos_sin_stock, required this.productos_desactivados, required this.producto_mas_vendido_nombre, required this.producto_mas_vendido_cantidad});

  factory ProductosStats.from_json(Map<String, dynamic> json) => ProductosStats(
    total_productos_activos: json['total_productos_activos'] ?? 0,
    productos_sin_stock: json['productos_sin_stock'] ?? 0,
    productos_desactivados: json['productos_desactivados'] ?? 0,
    producto_mas_vendido_nombre: json['producto_mas_vendido_nombre'] ?? 'n/a',
    producto_mas_vendido_cantidad: json['producto_mas_vendido_cantidad'] ?? 0,
  );
}

/// metricas de ingredientes para alertas de inventario
///
/// args:
///   total_ingredientes (int): cantidad de materias primas
///   ingredientes_stock_critico (int): por debajo del minimo absoluto
///   ingredientes_stock_bajo (int): cerca de agotarse
///   ingredientes_desactivados (int): fuera de uso
class IngredientesStats {
  final int total_ingredientes;
  final int ingredientes_stock_critico;
  final int ingredientes_stock_bajo;
  final int ingredientes_desactivados;

  IngredientesStats({required this.total_ingredientes, required this.ingredientes_stock_critico, required this.ingredientes_stock_bajo, required this.ingredientes_desactivados});

  factory IngredientesStats.from_json(Map<String, dynamic> json) => IngredientesStats(
    total_ingredientes: json['total_ingredientes'] ?? 0,
    ingredientes_stock_critico: json['ingredientes_stock_critico'] ?? 0,
    ingredientes_stock_bajo: json['ingredientes_stock_bajo'] ?? 0,
    ingredientes_desactivados: json['ingredientes_desactivados'] ?? 0,
  );
}

/// resumen del tipo de usuarios registrados en el sistema
///
/// args:
///   total_usuarios (int): suma de todas las cuentas
///   usuarios_admin (int): rol de administrador
///   usuarios_cliente (int): rol de cliente
///   usuarios_dependiente (int): rol de staff
///   usuarios_almacen (int): rol de gestion de inventario
class UsuariosStats {
  final int total_usuarios;
  final int usuarios_admin;
  final int usuarios_cliente;
  final int usuarios_dependiente;
  final int usuarios_almacen;

  UsuariosStats({required this.total_usuarios, required this.usuarios_admin, required this.usuarios_cliente, required this.usuarios_dependiente, required this.usuarios_almacen});

  factory UsuariosStats.from_json(Map<String, dynamic> json) => UsuariosStats(
    total_usuarios: json['total_usuarios'] ?? 0,
    usuarios_admin: json['usuarios_admin'] ?? 0,
    usuarios_cliente: json['usuarios_cliente'] ?? 0,
    usuarios_dependiente: json['usuarios_dependiente'] ?? 0,
    usuarios_almacen: json['usuarios_almacen'] ?? 0,
  );
}

/// informacion financiera de los pedidos completados
///
/// args:
///   ingresos_totales (double): suma de facturacion
///   total_pedidos_completados (int): pedidos cobrados
///   ticket_promedio (double): media de gasto por pedido
class VentasStats {
  final double ingresos_totales;
  final int total_pedidos_completados;
  final double ticket_promedio;

  VentasStats({required this.ingresos_totales, required this.total_pedidos_completados, required this.ticket_promedio});

  factory VentasStats.from_json(Map<String, dynamic> json) => VentasStats(
    ingresos_totales: double.tryParse(json['ingresos_totales'].toString()) ?? 0.0,
    total_pedidos_completados: json['total_pedidos_completados'] ?? 0,
    ticket_promedio: double.tryParse(json['ticket_promedio'].toString()) ?? 0.0,
  );
}

/// representa un punto de datos en la grafica temporal de pedidos
///
/// args:
///   fecha (String): la fecha del registro
///   total (int): la cantidad total de pedidos en esa fecha
class serie_pedidos_data {
  final String fecha;
  final int total;

  serie_pedidos_data({required this.fecha, required this.total});

  factory serie_pedidos_data.from_json(Map<String, dynamic> json) => serie_pedidos_data(
    fecha: json['fecha'] ?? '',
    total: json['total'] ?? 0,
  );
}

/// representa un punto de datos en la grafica temporal de ingresos
///
/// args:
///   fecha (String): la fecha del registro
///   total (double): la cantidad de ingresos generados en esa fecha
class serie_ingresos_data {
  final String fecha;
  final double total;

  serie_ingresos_data({required this.fecha, required this.total});

  factory serie_ingresos_data.from_json(Map<String, dynamic> json) => serie_ingresos_data(
    fecha: json['fecha'] ?? '',
    total: double.tryParse(json['total'].toString()) ?? 0.0,
  );
}

/// contenedor principal que agrupa todas las estadisticas del dashboard
///
/// args:
///   pedidos (PedidosStats): metricas de pedidos
///   productos (ProductosStats): metricas de productos
///   ingredientes (IngredientesStats): metricas de inventario
///   usuarios (UsuariosStats): metricas de cuentas
///   ventas (VentasStats): metricas financieras
///   periodo_inicio (String?): fecha de inicio del filtro
///   periodo_fin (String?): fecha de fin del filtro
///   series_pedidos (List<serie_pedidos_data>): datos temporales de los ultimos pedidos
///   series_ingresos (List<serie_ingresos_data>): datos temporales de los ultimos ingresos
class DashboardData {
  final PedidosStats pedidos;
  final ProductosStats productos;
  final IngredientesStats ingredientes;
  final UsuariosStats usuarios;
  final VentasStats ventas;
  final String? periodo_inicio;
  final String? periodo_fin;
  final List<serie_pedidos_data> series_pedidos;
  final List<serie_ingresos_data> series_ingresos;

  DashboardData({
    required this.pedidos, 
    required this.productos, 
    required this.ingredientes, 
    required this.usuarios, 
    required this.ventas, 
    this.periodo_inicio, 
    this.periodo_fin,
    this.series_pedidos = const [],
    this.series_ingresos = const []
  });

  factory DashboardData.from_json(Map<String, dynamic> json) => DashboardData(
    pedidos: PedidosStats.from_json(json['pedidos']),
    productos: ProductosStats.from_json(json['productos']),
    ingredientes: IngredientesStats.from_json(json['ingredientes']),
    usuarios: UsuariosStats.from_json(json['usuarios']),
    ventas: VentasStats.from_json(json['ventas']),
    periodo_inicio: json['periodo_inicio'],
    periodo_fin: json['periodo_fin'],
    series_pedidos: json['series_pedidos'] != null 
      ? (json['series_pedidos'] as List).map((i) => serie_pedidos_data.from_json(i)).toList() 
      : [],
    series_ingresos: json['series_ingresos'] != null 
      ? (json['series_ingresos'] as List).map((i) => serie_ingresos_data.from_json(i)).toList() 
      : [],
  );
}