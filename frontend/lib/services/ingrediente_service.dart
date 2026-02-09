import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingrediente.dart';

class ingrediente_service {
  static const String base_url = 'http://localhost:8000';

  // obtiene lista de todos los ingredientes activos
  Future<List<ingrediente>> get_ingredientes() async {
    //  simulacion activa
    await Future.delayed(const Duration(seconds: 1));
    return [
      ingrediente(ingrediente_id: 1, ingrediente_nombre: 'tomate', ingrediente_stock_actual: 5.0, ingrediente_stock_minimo: 10.0, ingrediente_unidad_medida: 'kg', ingrediente_precio_unitario: 1.5, estado_stock: 'bajo'),
    ];
    
    /* // --- código real ---
    final response = await http.get(Uri.parse('$base_url/ingredientes'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((i) => ingrediente.from_json(i)).toList();
    }
    throw Exception('error al cargar ingredientes');
    */
  }

  // crea un nuevo ingrediente en la bd
  Future<ingrediente> create_ingrediente(Map<String, dynamic> data) async {
    // --- simulación activa ---
    await Future.delayed(const Duration(seconds: 1));
    return ingrediente.from_json({...data, 'ingrediente_id': 99, 'estado_stock': 'normal'});

    /* // codigo real
    final response = await http.post(
      Uri.parse('$base_url/ingredientes'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return ingrediente.from_json(jsonDecode(response.body));
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error al crear');
    */
  }

  // elimina ingrediente usando soft delete
  Future<void> delete_ingrediente(int id) async {
    await Future.delayed(const Duration(seconds: 1)); // simulación
    /* // --- código real ---
    final response = await http.delete(Uri.parse('$base_url/ingredientes/$id'));
    if (response.statusCode != 204) throw Exception('error al eliminar');
    */
  }
}