// modelo para la relacion muchos a muchos entre productos e ingredientes
class producto_ingrediente {
  final int ingrediente_id;
  final String ingrediente_nombre;
  final double cantidad_necesaria;
  final String unidad_medida;

  producto_ingrediente({
    required this.ingrediente_id,
    required this.ingrediente_nombre,
    required this.cantidad_necesaria,
    required this.unidad_medida,
  });

  // mapea la relacion desde el json del detalle de producto
  factory producto_ingrediente.from_json(Map<String, dynamic> json) {
    return producto_ingrediente(
      ingrediente_id: json['ingrediente_id'],
      ingrediente_nombre: json['ingrediente_nombre'],
      cantidad_necesaria: (json['cantidad_necesaria'] as num).toDouble(),
      unidad_medida: json['unidad_medida'] ?? 'kg',
    );
  }
}