import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

// maneja el proceso de compra desde la perspectiva del cliente
class order_service {
  static const String base_url = 'http://localhost:8000';

  // comprueba stock y precios antes de confirmar el pago
  Future<bool> validate_cart(List<cart_item> items, {required int user_id, required String current_role}) async {
    final response = await http.post(
      Uri.parse('$base_url/pedidos/validar-carrito?user_id=$user_id&current_role=$current_role'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'items': items.map((i) => i.to_json()).toList()}),
    );
    if (response.statusCode == 200) return true;
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error validando carrito');
  }

  // transforma el carrito en un pedido formal en el sistema
  Future<order> create_order(List<cart_item> items, String notas, int user_id, {required String current_role}) async {
    final response = await http.post(
      Uri.parse('$base_url/pedidos/crear?user_id=$user_id&current_role=$current_role'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'items': items.map((i) => i.to_json()).toList(),
        'order_notes': notas
      }),
    );
    if (response.statusCode == 201) return order.from_json(jsonDecode(response.body));
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error creando pedido');
  }

  // historial de pedidos del usuario logueado
  Future<List<order>> list_orders(int user_id, {required String current_role}) async {
    final response = await http.get(
      Uri.parse('$base_url/pedidos/?user_id=$user_id&current_role=$current_role'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((o) => order.from_json(o)).toList();
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error cargando pedidos');
  }
}