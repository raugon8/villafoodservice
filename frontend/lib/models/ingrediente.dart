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

  factory ingrediente.from_json(Map<String, dynamic> json) {
    return ingrediente(
      ingrediente_id: json['ingrediente_id'],
      ingrediente_nombre: json['ingrediente_nombre'],
      // ✅ protección contra null en todos los campos numéricos
      ingrediente_stock_actual: double.parse((json['ingrediente_stockActual'] ?? 0).toString()),
      ingrediente_stock_minimo: double.parse((json['ingrediente_stockMinimo'] ?? 0).toString()),
      ingrediente_unidad_medida: json['ingrediente_unidadMedida'] ?? 'kg',
      ingrediente_precio_unitario: double.parse((json['ingrediente_precioUnitario'] ?? 0).toString()),
      estado_stock: json['estado_stock'] ?? 'normal',
    );
  }
}