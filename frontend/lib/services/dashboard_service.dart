import '../models/dashboard_model.dart';

class dashboard_service {
  Future<dashboard_data> get_stats(String periodo) async {
    await Future.delayed(const Duration(seconds: 1));
    return dashboard_data(
      pedidos: {'total': 50, 'entregados': 40, 'cancelados': 2},
      productos: {'activos': 15, 'sin_stock': 3},
      ingredientes: {'critico': 5, 'bajo': 8},
      ventas: {'ingresos': 1250.50, 'ticket_promedio': 25.10},
    );
  }
}