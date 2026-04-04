// Modelo para definir los alergenos europeos oficiales
class alergeno {
  final int id;
  final String nombre;

  alergeno({required this.id, required this.nombre});

  // Mapea la informacion del backend
  factory alergeno.from_json(Map<String, dynamic> json) {
    return alergeno(
      id: json['alergeno_id'],
      nombre: json['nombre'],
    );
  }
}