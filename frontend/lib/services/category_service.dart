import '../config/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

// construye los headers con el token JWT si esta disponible
Map<String, String> _build_headers({String? token, bool json = false}) {
  final headers = <String, String>{};
  if (json) headers['content-type'] = 'application/json';
  if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
  return headers;
}

// crud para las categorias del menu
class category_service {
  static const String base_url = AppConstants.apiUrl;

  // lista categorias pudiendo filtrar las inactivas
  Future<List<category_model>> list_categories({bool active_only = true}) async {
    final response = await http.get(
      Uri.parse('$base_url/categories/?active_only=$active_only'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((c) => category_model.from_json(c)).toList();
    }
    throw Exception('error al cargar categorias');
  }

  // crea categoria exigiendo credenciales en la url
  Future<category_model> create_category(
    String name,
    String? description, {
    required int user_id,
    required String current_role,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$base_url/categories/?user_id=$user_id&current_role=$current_role'),
      headers: _build_headers(token: token, json: true),
      body: jsonEncode({'category_name': name, 'category_description': description}),
    );
    if (response.statusCode == 201) {
      return category_model.from_json(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error al crear categoria');
  }

  // actualiza parcialmente una categoria (solo envia campos no nulos)
  Future<category_model> update_category(
    int id, {
    String? name,
    String? description,
    bool? active,
    required int user_id,
    required String current_role,
    String? token,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['category_name'] = name;
    if (description != null) body['category_description'] = description;
    if (active != null) body['category_active'] = active;

    final response = await http.patch(
      Uri.parse('$base_url/categories/$id?user_id=$user_id&current_role=$current_role'),
      headers: _build_headers(token: token, json: true),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return category_model.from_json(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error al actualizar categoria');
  }

  // marca la categoria como inactiva en lugar de borrarla
  Future<void> deactivate_category(
    int id, {
    required int user_id,
    required String current_role,
    String? token,
  }) async {
    final response = await http.delete(
      Uri.parse('$base_url/categories/$id?user_id=$user_id&current_role=$current_role'),
      headers: _build_headers(token: token),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('error al desactivar categoria');
    }
  }
}