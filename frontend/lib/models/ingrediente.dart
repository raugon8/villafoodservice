// modelo para gestionar ingredientes del inventario
class ingrediente {
  final int ingrediente_id;
  final String ingrediente_nombre;
  final double ingrediente_stock_actual;
  final double ingrediente_stock_minimo;
  final String ingrediente_unidad_medida;
  final double ingrediente_precio_unitario;
  final String estado_stock;

  ingrediente({
    required this.ingrediente_id,
    required this.ingrediente_nombre,
    required this.ingrediente_stock_actual,
    required this.ingrediente_stock_minimo,
    required this.ingrediente_unidad_medida,
    required this.ingrediente_precio_unitario,
    required this.estado_stock,
  });

  // mapea datos desde el json del servidor
  factory ingrediente.from_json(Map<String, dynamic> json) {
    return ingrediente(
      ingrediente_id: json['ingrediente_id'],
      ingrediente_nombre: json['ingrediente_nombre'],
      ingrediente_stock_actual: (json['ingrediente_stock_actual'] as num).toDouble(),
      ingrediente_stock_minimo: (json['ingrediente_stock_minimo'] as num).toDouble(),
      ingrediente_unidad_medida: json['ingrediente_unidad_medida'],
      ingrediente_precio_unitario: (json['ingrediente_precio_unitario'] as num).toDouble(),
      estado_stock: json['estado_stock'] ?? 'normal',
    );
  }
}