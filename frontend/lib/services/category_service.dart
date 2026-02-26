import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class category_service {
  static const String base_url = 'http://localhost:8000';

  Future<List<category_model>> list_categories({bool active_only = true}) async {
    final response = await http.get(
      Uri.parse('$base_url/categories/?active_only=$active_only'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((c) => category_model.from_json(c)).toList();
    }
    throw Exception('Error al cargar categorías');
  }

  Future<category_model> create_category(
    String name,
    String? description, {
    required int user_id,
    required String current_role,
  }) async {
    final response = await http.post(
      Uri.parse('$base_url/categories/?user_id=$user_id&current_role=$current_role'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'category_name': name, 'category_description': description}),
    );
    if (response.statusCode == 201) {
      return category_model.from_json(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Error al crear categoría');
  }

  Future<category_model> update_category(
    int id, {
    String? name,
    String? description,
    bool? active,
    required int user_id,
    required String current_role,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['category_name'] = name;
    if (description != null) body['category_description'] = description;
    if (active != null) body['category_active'] = active;

    final response = await http.patch(
      Uri.parse('$base_url/categories/$id?user_id=$user_id&current_role=$current_role'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return category_model.from_json(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Error al actualizar categoría');
  }

  Future<void> deactivate_category(
    int id, {
    required int user_id,
    required String current_role,
  }) async {
    final response = await http.delete(
      Uri.parse('$base_url/categories/$id?user_id=$user_id&current_role=$current_role'),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al desactivar categoría');
    }
  }
}