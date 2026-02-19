// modelo para la relacion muchos a muchos entre productos e ingredientes
class producto_ingrediente {
  final int ingrediente_id;
  final String ingrediente_nombre;
  final double cantidad_necesaria;
  final String? unidad_medida; // nullable — puede no venir del backend

  producto_ingrediente({
    required this.ingrediente_id,
    required this.ingrediente_nombre,
    required this.cantidad_necesaria,
    this.unidad_medida,
  });

  factory producto_ingrediente.from_json(Map<String, dynamic> json) {
    return producto_ingrediente(
      ingrediente_id: json['ingrediente_id'],
      ingrediente_nombre: json['ingrediente_nombre'],
      // convierte tanto String "1.0" como num 1.0 sin romper
      cantidad_necesaria: double.parse(json['cantidad_necesaria'].toString()),
      unidad_medida: json['unidad_medida'],
    );
  }
}