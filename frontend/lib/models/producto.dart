import 'alergeno_model.dart';

// modelo principal para representar productos y su disponibilidad
class producto {
  final int producto_id;
  final String producto_nombre;
  final String? producto_descripcion;
  final double producto_precio_unitario;
  final String producto_categoria;
  final int unidades_disponibles;
  final bool disponible;
  final String? image_url; 
  final List<alergeno> alergenos; 

  producto({
    required this.producto_id,
    required this.producto_nombre,
    this.producto_descripcion,
    required this.producto_precio_unitario,
    required this.producto_categoria,
    required this.unidades_disponibles,
    required this.disponible,
    this.image_url,
    required this.alergenos,
  });

  // extrae el json teniendo en cuenta el camelcase del backend y los nuevos campos
  factory producto.from_json(Map<String, dynamic> json) {
    // preparamos la lista vacia por si el backend aun no la envia
    var lista_alergenos = json['alergenos'] as List? ?? [];

    return producto(
      producto_id: json['producto_id'],
      producto_nombre: json['producto_nombre'],
      producto_descripcion: json['producto_descripcion'],
      producto_precio_unitario: double.parse(json['producto_precioUnitario'].toString()),
      producto_categoria: json['producto_categoria'],
      unidades_disponibles: json['unidades_disponibles'] ?? 0,
      disponible: json['disponible'] ?? false,
      image_url: json['image_url'],
      alergenos: lista_alergenos.map((a) => alergeno.from_json(a)).toList(),
    );
  }
}