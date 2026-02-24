class PedidosStats {
  final int total_pedidos;
  final int pedidos_pendientes;
  final int pedidos_en_preparacion;
  final int pedidos_listos;
  final int pedidos_entregados;
  final int pedidos_cancelados;

  PedidosStats({
    required this.total_pedidos,
    required this.pedidos_pendientes,
    required this.pedidos_en_preparacion,
    required this.pedidos_listos,
    required this.pedidos_entregados,
    required this.pedidos_cancelados,
  });

  factory PedidosStats.from_json(Map<String, dynamic> json) => PedidosStats(
    total_pedidos: json['total_pedidos'] ?? 0,
    pedidos_pendientes: json['pedidos_pendientes'] ?? 0,
    pedidos_en_preparacion: json['pedidos_en_preparacion'] ?? 0,
    pedidos_listos: json['pedidos_listos'] ?? 0,
    pedidos_entregados: json['pedidos_entregados'] ?? 0,
    pedidos_cancelados: json['pedidos_cancelados'] ?? 0,
  );
}

class ProductosStats {
  final int total_productos_activos;
  final int productos_sin_stock;
  final int productos_desactivados;
  final String producto_mas_vendido_nombre;
  final int producto_mas_vendido_cantidad;

  ProductosStats({
    required this.total_productos_activos,
    required this.productos_sin_stock,
    required this.productos_desactivados,
    required this.producto_mas_vendido_nombre,
    required this.producto_mas_vendido_cantidad,
  });

  factory ProductosStats.from_json(Map<String, dynamic> json) => ProductosStats(
    total_productos_activos: json['total_productos_activos'] ?? 0,
    productos_sin_stock: json['productos_sin_stock'] ?? 0,
    productos_desactivados: json['productos_desactivados'] ?? 0,
    producto_mas_vendido_nombre: json['producto_mas_vendido_nombre'] ?? 'N/A',
    producto_mas_vendido_cantidad: json['producto_mas_vendido_cantidad'] ?? 0,
  );
}

class IngredientesStats {
  final int total_ingredientes;
  final int ingredientes_stock_critico;
  final int ingredientes_stock_bajo;
  final int ingredientes_desactivados;

  IngredientesStats({
    required this.total_ingredientes,
    required this.ingredientes_stock_critico,
    required this.ingredientes_stock_bajo,
    required this.ingredientes_desactivados,
  });

  factory IngredientesStats.from_json(Map<String, dynamic> json) => IngredientesStats(
    total_ingredientes: json['total_ingredientes'] ?? 0,
    ingredientes_stock_critico: json['ingredientes_stock_critico'] ?? 0,
    ingredientes_stock_bajo: json['ingredientes_stock_bajo'] ?? 0,
    ingredientes_desactivados: json['ingredientes_desactivados'] ?? 0,
  );
}

class UsuariosStats {
  final int total_usuarios;
  final int usuarios_admin;
  final int usuarios_cliente;
  final int usuarios_dependiente;
  final int usuarios_almacen;

  UsuariosStats({
    required this.total_usuarios,
    required this.usuarios_admin,
    required this.usuarios_cliente,
    required this.usuarios_dependiente,
    required this.usuarios_almacen,
  });

  factory UsuariosStats.from_json(Map<String, dynamic> json) => UsuariosStats(
    total_usuarios: json['total_usuarios'] ?? 0,
    usuarios_admin: json['usuarios_admin'] ?? 0,
    usuarios_cliente: json['usuarios_cliente'] ?? 0,
    usuarios_dependiente: json['usuarios_dependiente'] ?? 0,
    usuarios_almacen: json['usuarios_almacen'] ?? 0,
  );
}

class VentasStats {
  final double ingresos_totales;
  final int total_pedidos_completados;
  final double ticket_promedio;

  VentasStats({
    required this.ingresos_totales,
    required this.total_pedidos_completados,
    required this.ticket_promedio,
  });

  factory VentasStats.from_json(Map<String, dynamic> json) => VentasStats(
    ingresos_totales: double.tryParse(json['ingresos_totales'].toString()) ?? 0.0,
    total_pedidos_completados: json['total_pedidos_completados'] ?? 0,
    ticket_promedio: double.tryParse(json['ticket_promedio'].toString()) ?? 0.0,
  );
}

class DashboardData {
  final PedidosStats pedidos;
  final ProductosStats productos;
  final IngredientesStats ingredientes;
  final UsuariosStats usuarios;
  final VentasStats ventas;
  final String? periodo_inicio;
  final String? periodo_fin;

  DashboardData({
    required this.pedidos,
    required this.productos,
    required this.ingredientes,
    required this.usuarios,
    required this.ventas,
    this.periodo_inicio,
    this.periodo_fin,
  });

  factory DashboardData.from_json(Map<String, dynamic> json) => DashboardData(
    pedidos: PedidosStats.from_json(json['pedidos']),
    productos: ProductosStats.from_json(json['productos']),
    ingredientes: IngredientesStats.from_json(json['ingredientes']),
    usuarios: UsuariosStats.from_json(json['usuarios']),
    ventas: VentasStats.from_json(json['ventas']),
    periodo_inicio: json['periodo_inicio'],
    periodo_fin: json['periodo_fin'],
  );
}