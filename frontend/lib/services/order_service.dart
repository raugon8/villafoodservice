import '../config/app_constants.dart';
import 'dart:convert';
import 'dart:async'; // necesario para manejar los TimeoutException
import 'package:flutter/foundation.dart'; // necesario para usar compute()
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

// --- funcion aislada para procesar la lista de pedidos en segundo plano ---
List<order> _parse_orders_list(String response_body) {
  final List data = jsonDecode(response_body);
  return data.map((o) => order.from_json(o)).toList();
}
// --------------------------------------------------------------------------

// maneja el proceso de compra desde la perspectiva del cliente
class order_service {
  static const String base_url = AppConstants.apiUrl;
  static const Duration timeout_duration = Duration(seconds: 10); // limite de 10 segundos

  // comprueba stock y precios antes de confirmar el pago
  Future<bool> validate_cart(List<cart_item> items, {required int user_id, required String current_role}) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/pedidos/validar-carrito?user_id=$user_id&current_role=$current_role'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'items': items.map((i) => i.to_json()).toList()}),
      ).timeout(timeout_duration);
      
      if (response.statusCode == 200) return true;
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error validando carrito');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado en validar el carrito. comprueba tu conexion.');
    }
  }

  // transforma el carrito en un pedido formal en el sistema
  Future<order> create_order(List<cart_item> items, String notas, int user_id, {required String current_role}) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/pedidos/crear?user_id=$user_id&current_role=$current_role'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'items': items.map((i) => i.to_json()).toList(),
          'order_notes': notas
        }),
      ).timeout(timeout_duration);
      
      if (response.statusCode == 201) return order.from_json(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error creando pedido');
    } on TimeoutException {
      throw Exception('el servidor ha tardado demasiado en crear el pedido. reintenta por favor.');
    }
  }

  // historial de pedidos del usuario logueado
  Future<List<order>> list_orders(int user_id, {required String current_role}) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/pedidos/?user_id=$user_id&current_role=$current_role'),
      ).timeout(timeout_duration);
      
      if (response.statusCode == 200) {
        // usamos compute para que la UI no se congele al procesar el historial
        return await compute(_parse_orders_list, response.body);
      }
      throw Exception(jsonDecode(response.body)['detail'] ?? 'error cargando pedidos');
    } on TimeoutException {
      throw Exception('ha tardado demasiado en cargar tus pedidos. comprueba tu conexion y reintenta.');
    }
  }
}

