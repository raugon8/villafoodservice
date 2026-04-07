import '../config/app_constants.dart';
import 'dart:convert';
import 'dart:async'; 
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../models/producto_ingrediente.dart';

List<producto> _parse_productos_list(String response_body) {
  final List data = jsonDecode(response_body);
  return data.map((p) => producto.from_json(p)).toList();
}

List<producto> _parse_search_results(String response_body) {
  final data = jsonDecode(response_body);
  final List products = data['products'];
  return products.map((p) => producto.from_json(p)).toList();
}

class producto_service {
  static const String base_url = AppConstants.apiUrl;
  static const Duration timeout_duration = Duration(seconds: 10);

  // Helper para cabeceras con JWT
  Map<String, String> _headers(String? token) {
    if (token != null) {
      return {'content-type': 'application/json', 'Authorization': 'Bearer $token'};
    }
    return {'content-type': 'application/json'};
  }

  Future<List<producto>> get_productos({String? token}) async {
    try {
      final response = await http.get(Uri.parse('$base_url/productos/'), headers: _headers(token))
          .timeout(timeout_duration);
          
      if (response.statusCode == 200) {
        return await compute(_parse_productos_list, response.body);
      }
      throw Exception('error al cargar productos');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado en responder. por favor, reintenta.');
    }
  }

  Future<producto> get_producto(int id, {String? token}) async {
    try {
      final response = await http.get(Uri.parse('$base_url/productos/$id'), headers: _headers(token))
          .timeout(timeout_duration);
      if (response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
      throw Exception('error al obtener producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado en responder.');
    }
  }

  //parametros en URL. Usamos JWT.
  Future<producto> create_producto(Map<String, dynamic> data, {required String token}) async {
    final uri = Uri.parse('$base_url/productos/');
    try {
      final response = await http.post(uri, headers: _headers(token), body: jsonEncode(data))
          .timeout(timeout_duration);
      if (response.statusCode == 201 || response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error al crear producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado. comprueba tu conexion.');
    }
  }

  Future<producto> update_producto(int id, Map<String, dynamic> data, {required String token}) async {
    final uri = Uri.parse('$base_url/productos/$id');
    try {
      final response = await http.put(uri, headers: _headers(token), body: jsonEncode(data))
          .timeout(timeout_duration);
      if (response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error al actualizar producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  Future<void> delete_producto(int id, {required String token}) async {
    final uri = Uri.parse('$base_url/productos/$id');
    try {
      final response = await http.delete(uri, headers: _headers(token)).timeout(timeout_duration);
      if (response.statusCode != 204 && response.statusCode != 200) throw Exception('error al eliminar producto');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  // NUEVO: Botón de Pánico (Toggle Stock)
  Future<producto> toggle_stock(int id, {required String token}) async {
    final uri = Uri.parse('$base_url/productos/$id/toggle-stock');
    try {
      final response = await http.patch(uri, headers: _headers(token))
          .timeout(timeout_duration);
      if (response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error al cambiar stock');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  Future<List<producto>> search_products({
    required String token,
    String? query,
    String? service,
    List<int>? category_ids,
    bool available_only = false,
    double? min_price,
    double? max_price,
    bool active_only = true,
    String sort_by = 'name_asc',
    int skip = 0,
    int limit = 20,
  }) async {
    String url = '$base_url/productos/search?sort_by=$sort_by&skip=$skip&limit=$limit&active_only=$active_only&available_only=$available_only';
    if (query != null && query.isNotEmpty) url += '&search_query=$query';
    if (service != null) url += '&service=$service';
    if (category_ids != null && category_ids.isNotEmpty) {
      for (final id in category_ids) {
        url += '&category_ids=$id';
      }
    }
    if (min_price != null) url += '&min_price=$min_price';
    if (max_price != null) url += '&max_price=$max_price';

    try {
      final response = await http.get(Uri.parse(url), headers: _headers(token)).timeout(timeout_duration);
      if (response.statusCode == 200) {
        return await compute(_parse_search_results, response.body);
      }
      throw Exception('error en busqueda de productos');
    } on TimeoutException {
      throw Exception('la busqueda ha tardado demasiado en responder. revisa tu conexion e intentalo de nuevo.');
    }
  }

  Future<List<producto_ingrediente>> get_ingredientes_producto(int producto_id, {String? token}) async {
    try {
      final response = await http.get(Uri.parse('$base_url/productos/$producto_id'), headers: _headers(token))
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

  Future<void> agregar_ingrediente(int producto_id, int ingrediente_id, double cantidad, {required String token}) async {
    final uri = Uri.parse('$base_url/productos/$producto_id/ingredientes');
    try {
      final response = await http.post(uri, headers: _headers(token), body: jsonEncode({'ingrediente_id': ingrediente_id, 'cantidad_necesaria': cantidad}))
          .timeout(timeout_duration);
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception(jsonDecode(response.body)['detail'] ?? 'error al agregar ingrediente');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }

  Future<void> quitar_ingrediente(int producto_id, int ingrediente_id, {required String token}) async {
    final uri = Uri.parse('$base_url/productos/$producto_id/ingredientes/$ingrediente_id');
    try {
      final response = await http.delete(uri, headers: _headers(token)).timeout(timeout_duration);
      if (response.statusCode != 200 && response.statusCode != 204) throw Exception(jsonDecode(response.body)['detail'] ?? 'error al quitar ingrediente');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado.');
    }
  }
}