import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import 'api_service.dart';

/// puente de comunicacion con el backend para la gestion del historial del cliente
/// permite consultar los pedidos anteriores y comprobar disponibilidad para repetirlos
class historial_service {
  // usamos la base url de tu api service existente
  final String base_url = api_service.base_url;

  /// solicita al backend la lista completa de pedidos anteriores de un cliente especifico
  ///
  /// args:
  ///   user_id (int): el identificador unico del cliente
  ///   current_role (String): el rol con el que actua (debe ser cliente)
  Future<List<order>> get_historial(int user_id, String current_role) async {
    final url = Uri.parse('$base_url/pedidos/historial');
    final response = await http.get(
      url,
      headers: {
        'x-user-id': user_id.toString(),
        'x-user-role': current_role,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => order.from_json(json)).toList();
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
  Future<Map<String, dynamic>> repetir_pedido(int pedido_id, int user_id, String current_role) async {
    final url = Uri.parse('$base_url/pedidos/repetir/$pedido_id');
    final response = await http.post(
      url,
      headers: {
        'x-user-id': user_id.toString(),
        'x-user-role': current_role,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('fallo al verificar el stock del pedido');
    }
  }
}