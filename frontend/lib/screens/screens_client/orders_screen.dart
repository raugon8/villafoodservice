import 'package:flutter/material.dart';
import '../../../services/order_service.dart';
import '../../../models/order_model.dart';

class orders_screen extends StatefulWidget {
  const orders_screen({super.key});
  @override
  State<orders_screen> createState() => _orders_screen_state();
}

class _orders_screen_state extends State<orders_screen> {
  final service_instancia = order_service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('mis pedidos')),
      body: FutureBuilder<List<order>>(
        future: service_instancia.list_orders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('no has hecho pedidos aun'));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('pedido #${item.pedido_id}'),
                  subtitle: Text('estado: ${item.pedido_estado} - total: €${item.pedido_total}'),
                  // colores segun el estado del pedido
                  trailing: Icon(Icons.circle, color: item.pedido_estado == 'entregado' ? Colors.green : Colors.orange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}