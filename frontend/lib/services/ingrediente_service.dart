import '../config/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingrediente.dart';

// logica de red para el crud del inventario
class ingrediente_service {
  static const String base_url = AppConstants.apiUrl;

  // Helper para generar cabeceras con JWT
  Map<String, String> _headers(String? token) {
    if (token != null && token.isNotEmpty) {
      return {'content-type': 'application/json', 'Authorization': 'Bearer $token'};
    }
    return {'content-type': 'application/json'};
  }

  // obtiene todo el stock actual
  Future<List<ingrediente>> get_ingredientes({String? token}) async {
    final response = await http.get(
      Uri.parse('$base_url/ingredientes/'), // ¡Adiós a los parámetros en la URL!
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((i) => ingrediente.from_json(i)).toList();
    }
    throw Exception('error al cargar ingredientes');
  }

  // registra un ingrediente nuevo en la base de datos
  Future<ingrediente> create_ingrediente(Map<String, dynamic> data, {required String token}) async {
    final response = await http.post(
      Uri.parse('$base_url/ingredientes/'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return ingrediente.from_json(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'error al crear');
  }

  // sobrescribe los datos de un ingrediente existente
  Future<ingrediente> update_ingrediente(int id, Map<String, dynamic> data, {required String token}) async {
    final response = await http.put(
      Uri.parse('$base_url/ingredientes/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return ingrediente.from_json(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'error al actualizar');
  }

  // borra el ingrediente permanentemente
  Future<void> delete_ingrediente(int id, {required String token}) async {
    final response = await http.delete(
      Uri.parse('$base_url/ingredientes/$id'),
      headers: _headers(token),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('error al eliminar');
    }
  }
}