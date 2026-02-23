import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';

class dashboard_service {
  static const String base_url = 'http://localhost:8000';

  Future<dashboard_data> get_stats(String periodo, {int user_id = 1}) async {
    final pedidos_res      = await http.get(Uri.parse('$base_url/pedidos/?user_id=$user_id&skip=0&limit=1000'));
    final productos_res    = await http.get(Uri.parse('$base_url/productos/'));
    final ingredientes_res = await http.get(Uri.parse('$base_url/ingredientes/'));

    Map<String, dynamic> pedidos_stats = {'total': 0, 'entregados': 0, 'cancelados': 0};
    Map<String, dynamic> ventas_stats  = {'ingresos': 0.0, 'ticket_promedio': 0.0};
    if (pedidos_res.statusCode == 200) {
      final List<dynamic> pedidos = jsonDecode(pedidos_res.body);
      int entregados = pedidos.where((p) => p['order_status'] == 'entregado').length;
      int cancelados = pedidos.where((p) => p['order_status'] == 'cancelado').length;
      double total_ingresos = pedidos
        .where((p) => p['order_status'] != 'cancelado')
        .fold(0.0, (sum, p) => sum + (p['order_total'] as num).toDouble());
      pedidos_stats = {
        'total':      pedidos.length,
        'entregados': entregados,
        'cancelados': cancelados,
      };
      ventas_stats = {
        'ingresos':        total_ingresos,
        'ticket_promedio': pedidos.isEmpty ? 0.0 : total_ingresos / pedidos.length,
      };
    }

    Map<String, dynamic> productos_stats = {'activos': 0, 'sin_stock': 0};
    if (productos_res.statusCode == 200) {
      final List<dynamic> productos = jsonDecode(productos_res.body);
      productos_stats = {
        'activos':   productos.length,
        'sin_stock': productos.where((p) => (p['available_units'] ?? 0) == 0).length,
      };
    }

    Map<String, dynamic> ingredientes_stats = {'critico': 0, 'bajo': 0};
    if (ingredientes_res.statusCode == 200) {
      final List<dynamic> ingredientes = jsonDecode(ingredientes_res.body);
      ingredientes_stats = {
        'critico': ingredientes.where((i) => (i['stock_actual'] ?? 0) == 0).length,
        'bajo':    ingredientes.where((i) => (i['stock_actual'] ?? 0) > 0 && (i['stock_actual'] ?? 0) < 10).length,
      };
    }

    return dashboard_data(
      pedidos:      pedidos_stats,
      productos:    productos_stats,
      ingredientes: ingredientes_stats,
      ventas:       ventas_stats,
    );
  }
}