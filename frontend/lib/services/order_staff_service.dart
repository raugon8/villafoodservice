import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_staff_model.dart';

class order_staff_service {
  static const String base_url = 'http://localhost:8000';

  // lista pedidos filtrados por servicio (cafeteria, restaurante, etc)
  Future<List<order_staff_item>> list_staff_orders(String servicio) async {
    // simulacion para la tarea 6
    await Future.delayed(const Duration(seconds: 1));
    return [
      order_staff_item(
        pedido_id: 601, 
        usuario_nombre: 'juan perez', 
        pedido_estado: 'pendiente', 
        pedido_total: 12.0, 
        es_nuevo: true, 
        pedido_notas: 'sin cebolla'
      ),
    ];
  }

  // actualiza el estado del pedido: pendiente -> en_preparacion -> listo
  Future<void> update_order_status(int id, String nuevo_estado) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}