import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_model.dart';

class dashboard_screen extends StatelessWidget {
  const dashboard_screen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = dashboard_service();
    return Scaffold(
      appBar: AppBar(title: const Text('panel administrativo')),
      body: FutureBuilder<dashboard_data>(
        future: service.get_stats('mes'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            children: [
              _card_stats('ingresos', '€${data.ventas['ingresos']}', Colors.green),
              _card_stats('pedidos', '${data.pedidos['total']}', Colors.blue),
              _card_stats('stock critico', '${data.ingredientes['critico']}', Colors.red),
              _card_stats('sin stock', '${data.productos['sin_stock']}', Colors.orange),
            ],
          );
        },
      ),
    );
  }

  Widget _card_stats(String titulo, String valor, Color color) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(valor, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(titulo),
        ],
      ),
    );
  }
}