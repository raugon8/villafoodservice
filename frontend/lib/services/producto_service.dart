import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class producto_service {
  static const String base_url = 'http://localhost:8000';

  // obtiene todos los productos
  Future<List<producto>> get_productos() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      producto(
        producto_id: 1, 
        producto_nombre: 'bocadillo jamon', 
        producto_descripcion: 'con queso', 
        producto_precio_unitario: 3.50, 
        producto_categoria: 'restaurante', 
        unidades_disponibles: 3, 
        disponible: true
      ),
    ];
  }

  // TAREA 9: Metodo de busqueda avanzada para conectar con el backend de Raul
  Future<List<producto>> search_products({
    String? query,
    int? category_id,
    double? min_price,
    double? max_price,
    String? sort_by,
  }) async {
    // Simulamos la respuesta mientras Raul termina el endpoint /products/search
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Aqui iran los query params segun la guia de busqueda
    // final response = await http.get(Uri.parse('$base_url/products/search?search_query=$query&category_id=$category_id...'));
    
    return get_productos(); // De momento devuelve la lista base
  }
}