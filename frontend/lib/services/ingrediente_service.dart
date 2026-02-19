import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingrediente.dart';

class ingrediente_service {
  static const String base_url = 'http://localhost:8000';

  Future<List<ingrediente>> get_ingredientes() async {
    final response = await http.get(Uri.parse('$base_url/ingredientes/'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((i) => ingrediente.from_json(i)).toList();
    }
    throw Exception('error al cargar ingredientes');
  }

  Future<ingrediente> create_ingrediente(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$base_url/ingredientes/'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return ingrediente.from_json(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'error al crear');
  }

  // ✅ nuevo — actualiza un ingrediente existente
  Future<ingrediente> update_ingrediente(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$base_url/ingredientes/$id'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return ingrediente.from_json(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'error al actualizar');
  }

  Future<void> delete_ingrediente(int id) async {
    final response = await http.delete(Uri.parse('$base_url/ingredientes/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('error al eliminar');
    }
  }
}