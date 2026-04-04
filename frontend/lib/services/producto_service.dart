import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../models/producto_ingrediente.dart';

// conexion principal para el crud de productos y sus recetas
class producto_service {
  static const String base_url = 'http://localhost:8000';

  // lista todos los productos sin filtros
  Future<List<producto>> get_productos() async {
    final response = await http.get(Uri.parse('$base_url/productos/'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((p) => producto.from_json(p)).toList();
    }
    throw Exception('error al cargar productos');
  }

  Future<producto> get_producto(int id) async {
    final response = await http.get(Uri.parse('$base_url/productos/$id'));
    if (response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
    throw Exception('error al obtener producto');
  }

  // inyecta parametros de seguridad en la url para crear el producto
  Future<producto> create_producto(Map<String, dynamic> data, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/').replace(queryParameters: {
      'user_id': user_id.toString(), 'current_role': current_role,
    });
    final response = await http.post(uri, headers: {'content-type': 'application/json'}, body: jsonEncode(data));
    if (response.statusCode == 201 || response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error al crear producto');
  }

  // inyecta parametros de seguridad en la url para actualizar el producto
  Future<producto> update_producto(int id, Map<String, dynamic> data, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$id').replace(queryParameters: {
      'user_id': user_id.toString(), 'current_role': current_role,
    });
    final response = await http.put(uri, headers: {'content-type': 'application/json'}, body: jsonEncode(data));
    if (response.statusCode == 200) return producto.from_json(jsonDecode(response.body));
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error al actualizar producto');
  }

  Future<void> delete_producto(int id, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$id').replace(queryParameters: {
      'user_id': user_id.toString(), 'current_role': current_role,
    });
    final response = await http.delete(uri);
    if (response.statusCode != 204 && response.statusCode != 200) throw Exception('error al eliminar producto');
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

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];
      return products.map((p) => producto.from_json(p)).toList();
    }
    throw Exception('error en busqueda de productos');
  }

  // --- ingredientes del producto ---

  // recupera la receta tecnica de un producto especifico
  Future<List<producto_ingrediente>> get_ingredientes_producto(int producto_id) async {
    final response = await http.get(Uri.parse('$base_url/productos/$producto_id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List lista = data['ingredientes'] ?? [];
      return lista.map((i) => producto_ingrediente.from_json(i)).toList();
    }
    throw Exception('error al obtener ingredientes del producto');
  }

  // asocia un ingrediente al producto definiendo su cantidad necesaria
  Future<void> agregar_ingrediente(int producto_id, int ingrediente_id, double cantidad, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$producto_id/ingredientes').replace(queryParameters: {'user_id': user_id.toString(), 'current_role': current_role});
    final response = await http.post(uri, headers: {'content-type': 'application/json'}, body: jsonEncode({'ingrediente_id': ingrediente_id, 'cantidad_necesaria': cantidad}));
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception(jsonDecode(response.body)['detail'] ?? 'error al agregar ingrediente');
  }

  // desvincula un ingrediente de la receta del producto
  Future<void> quitar_ingrediente(int producto_id, int ingrediente_id, {required int user_id, required String current_role}) async {
    final uri = Uri.parse('$base_url/productos/$producto_id/ingredientes/$ingrediente_id').replace(queryParameters: {'user_id': user_id.toString(), 'current_role': current_role});
    final response = await http.delete(uri);
    if (response.statusCode != 200 && response.statusCode != 204) throw Exception(jsonDecode(response.body)['detail'] ?? 'error al quitar ingrediente');
  }
}