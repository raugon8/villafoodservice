import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class order_service {
  static const String base_url = 'http://localhost:8000';

  // envia el carrito para validar disponibilidad y precios
  Future<bool> validate_cart(List<cart_item> items) async {
    // simulacion: siempre devuelve disponible por ahora
    await Future.delayed(const Duration(seconds: 1));
    return true; 
  }

  // confirma el pedido y actualiza stock en el servidor
  Future<order> create_order(List<cart_item> items, String notas) async {
    // simulacion de creacion de pedido exitosa
    await Future.delayed(const Duration(seconds: 1));
    return order(
      pedido_id: 505,
      pedido_estado: 'pendiente',
      pedido_total: 15.50,
      pedido_fecha_hora: DateTime.now(),
      detalles: []
    );
  }

  // lista los pedidos del usuario (nombre corregido)
  Future<List<order>> list_orders() async {
    // simulacion de historial de pedidos
    await Future.delayed(const Duration(seconds: 1));
    return [
      order(
        pedido_id: 1, 
        pedido_estado: 'pendiente', 
        pedido_total: 10.50, 
        pedido_fecha_hora: DateTime.now(), 
        detalles: []
      )
    ];
  }

  // --- codigo real para conectar ---
  /*
  Future<order> create_order_real(List<cart_item> items, String notas) async {
    final response = await http.post(
      Uri.parse('$base_url/pedidos/crear?usuario_id=1'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'items': items.map((i) => i.to_json()).toList(),
        'pedido_notas': notas
      }),
    );
    if (response.statusCode == 201) return order.from_json(jsonDecode(response.body));
    throw Exception('error al crear pedido');
  }
  */
}