import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import 'api_service.dart';
/// puente de comunicacion con el backend para la gestion del historial del cliente
/// permite consultar los pedidos anteriores y comprobar disponibilidad para repetirlos
class historial_service {
  // usamos la base url de tu api service existente
  final String base_url = api_service.base_url;
  // construye los headers con el token JWT si esta disponible
  Map<String, String> _build_headers({String? token, bool json = false}) {
    final headers = <String, String>{};
    if (json) headers['content-type'] = 'application/json';
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }
  /// solicita al backend la lista completa de pedidos anteriores de un cliente especifico
  ///
  /// args:
  ///   user_id (int): el identificador unico del cliente
  ///   current_role (String): el rol con el que actua (debe ser cliente)
  Future<List<historial_pedido>> get_historial(int user_id, String current_role, {String? token}) async {
    final url = Uri.parse('$base_url/pedidos/historial?user_id=$user_id&current_role=$current_role');
    final response = await http.get(url, headers: _build_headers(token: token));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => historial_pedido.from_json(json)).toList();
    } else {
      throw Exception('no se pudo cargar el historial');
    }
  }
  /// evalua contra el backend si los productos de un pedido anterior siguen disponibles
  ///
  /// args:
  ///   pedido_id (int): el numero de pedido que el cliente quiere volver a comprar
  ///   user_id (int): el identificador unico del cliente
  ///   current_role (String): el rol con el que actua (debe ser cliente)
  Future<Map<String, dynamic>> repetir_pedido(int pedido_id, int user_id, String current_role, {String? token}) async {
    final url = Uri.parse('$base_url/pedidos/repetir/$pedido_id?user_id=$user_id&current_role=$current_role');
    final response = await http.post(url, headers: _build_headers(token: token));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('fallo al verificar el stock del pedido');
    }
  }
  /// marca un pedido en estado listo como entregado desde el lado del cliente
  ///
  /// args:
  ///   pedido_id (int): el numero de pedido a marcar como entregado
  ///   user_id (int): el identificador unico del cliente
  ///   current_role (String): el rol con el que actua (debe ser cliente)
  Future<void> marcar_entregado(int pedido_id, int user_id, String current_role, {String? token}) async {
    final url = Uri.parse('$base_url/pedidos/$pedido_id/estado?user_id=$user_id&current_role=$current_role');
    final response = await http.patch(
      url,
      headers: _build_headers(token: token, json: true),
      body: json.encode({'order_status': 'entregado'}),
    );
    if (response.statusCode != 200) {
      throw Exception('no se pudo marcar el pedido como entregado');
    }
  }
}