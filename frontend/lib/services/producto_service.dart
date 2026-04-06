import '../config/app_constants.dart';
import 'dart:convert';
import 'dart:async'; // necesario para manejar los TimeoutException
import 'package:flutter/foundation.dart'; // necesario para usar compute()
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../models/producto_ingrediente.dart';

// --- funciones de parseo aisladas para usar con compute() ---
// deben ser de nivel superior (fuera de la clase) para correr en otro hilo
List<producto> _parse_productos_list(String response_body) {
  final List data = jsonDecode(response_body);
  return data.map((p) => producto.from_json(p)).toList();
}

List<producto> _parse_search_results(String response_body) {
  final data = jsonDecode(response_body);
  final List products = data['products'];
  return products.map((p) => producto.from_json(p)).toList();
}


// conexion principal para el crud de productos y sus recetas
class producto_service {
  static const String base_url = AppConstants.apiUrl;
  static const Duration timeout_duration = Duration(seconds: 10);

  // lista todos los productos sin filtros, optimizado con compute y timeout
  Future<List<producto>> get_productos() async {
    try {
      final response = await http.get(Uri.parse('$base_url/productos/'))
          .timeout(timeout_duration);
          
      if (response.statusCode == 200) {
        // movemos el parseo del json a un hilo secundario para no congelar la UI
        return await compute(_parse_productos_list, response.body);
      }
      throw Exception('error al cargar productos');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado en responder. por favor, reintenta.');
    }
  }

  Future<producto> get_producto(int id) async {
    try {
      final response = await http.get(Uri.parse('$base_url/productos/$id'))
          .timeout(timeout_duration);
      if (response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
      throw Exception('error al obtener producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado en responder.');
    }
  }

  // inyecta parametros de seguridad en la url para crear el producto
  Future<producto> create_producto(Map<String, dynamic> data, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/').replace(queryParameters: {
      'user_id': user_id.toString(), 'current_role': current_role,
    });
    try {
      final response = await http.post(uri, headers: {'content-type': 'application/json'}, body: jsonEncode(data))
          .timeout(timeout_duration);
      if (response.statusCode == 201 || response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error al crear producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado. comprueba tu conexion.');
    }
  }

  // inyecta parametros de seguridad en la url para actualizar el producto
  Future<producto> update_producto(int id, Map<String, dynamic> data, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$id').replace(queryParameters: {
      'user_id': user_id.toString(), 'current_role': current_role,
    });
    try {
      final response = await http.put(uri, headers: {'content-type': 'application/json'}, body: jsonEncode(data))
          .timeout(timeout_duration);
      if (response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error al actualizar producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  Future<void> delete_producto(int id, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$id').replace(queryParameters: {
      'user_id': user_id.toString(), 'current_role': current_role,
    });
    try {
      final response = await http.delete(uri).timeout(timeout_duration);
      if (response.statusCode != 204 && response.statusCode != 200) throw Exception('error al eliminar producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  // endpoint complejo (tarea 9): procesa todos los filtros del buscador desde la app
  Future<List<producto>> search_products({
    required int user_id,
    required String current_role,
    String? query,
    String? service,
    int? category_id,
    bool available_only = false,
    double? min_price,
    double? max_price,
    bool active_only = true,
    String sort_by = 'name_asc',
    int skip = 0,
    int limit = 20,
  }) async {
    String url = '$base_url/productos/search?current_role=$current_role&sort_by=$sort_by&skip=$skip&limit=$limit&active_only=$active_only&available_only=$available_only';
    if (query != null && query.isNotEmpty) url += '&search_query=$query';
    if (service != null) url += '&service=$service';
    if (category_id != null) url += '&category_id=$category_id';
    if (min_price != null) url += '&min_price=$min_price';
    if (max_price != null) url += '&max_price=$max_price';

    try {
      final response = await http.get(Uri.parse(url)).timeout(timeout_duration);
      if (response.statusCode == 200) {
        // usamos compute para que la busqueda no trabe la interfaz si hay muchos resultados
        return await compute(_parse_search_results, response.body);
      }
      throw Exception('error en busqueda de productos');
    } on TimeoutException {
      throw Exception('la busqueda ha tardado demasiado en responder. revisa tu conexion e intentalo de nuevo.');
    }
  }

  // --- ingredientes del producto ---

  // recupera la receta tecnica de un producto especifico
  Future<List<producto_ingrediente>> get_ingredientes_producto(int producto_id) async {
    try {
      final response = await http.get(Uri.parse('$base_url/productos/$producto_id'))
          .timeout(timeout_duration);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List lista = data['ingredientes'] ?? [];
        return lista.map((i) => producto_ingrediente.from_json(i)).toList();
      }
      throw Exception('error al obtener ingredientes del producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  // asocia un ingrediente al producto definiendo su cantidad necesaria
  Future<void> agregar_ingrediente(int producto_id, int ingrediente_id, double cantidad, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$producto_id/ingredientes').replace(queryParameters: {'user_id': user_id.toString(), 'current_role': current_role});
    try {
      final response = await http.post(uri, headers: {'content-type': 'application/json'}, body: jsonEncode({'ingrediente_id': ingrediente_id, 'cantidad_necesaria': cantidad}))
          .timeout(timeout_duration);
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception(jsonDecode(response.body)['detail'] ?? 'error al agregar ingrediente');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  // desvincula un ingrediente de la receta del producto
  Future<void> quitar_ingrediente(int producto_id, int ingrediente_id, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$producto_id/ingredientes/$ingrediente_id').replace(queryParameters: {'user_id': user_id.toString(), 'current_role': current_role});
    try {
      final response = await http.delete(uri).timeout(timeout_duration);
      if (response.statusCode != 200 && response.statusCode != 204) throw Exception(jsonDecode(response.body)['detail'] ?? 'error al quitar ingrediente');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }
}

