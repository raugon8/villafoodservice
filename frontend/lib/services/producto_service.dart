import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class producto_service {
  static const String base_url = 'http://localhost:8000';

  // obtiene todos los productos con su stock calculado
  Future<List<producto>> get_productos() async {
    // --- simulacion activa ---
    await Future.delayed(const Duration(seconds: 1));
    return [
      producto(
        producto_id: 1, 
        producto_nombre: 'bocadillo jamon', 
        producto_descripcion: 'con queso', 
        producto_precio_unitario: 3.50, 
        producto_categoria: 'restaurante', 
        unidades_disponibles: 3, // calculado segun ingredientes
        disponible: true
      ),
    ];
    // codigo real comentado
    /* final response = await http.get(Uri.parse('$base_url/productos'));
       if (response.statusCode == 200) {
         List data = jsonDecode(response.body);
         return data.map((p) => producto.from_json(p)).toList();
       } throw Exception('error carga productos'); */
  }
}