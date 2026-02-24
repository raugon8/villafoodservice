import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/order_service.dart';
import '../../../models/order_model.dart';
import '../../../providers/auth_provider.dart';

class orders_screen extends StatefulWidget {
  const orders_screen({super.key});
  @override
  State<orders_screen> createState() => _orders_screen_state();
}

class _orders_screen_state extends State<orders_screen> {
  final service_instancia = order_service();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<auth_provider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('mis pedidos')),
      body: FutureBuilder<List<order>>(
        future: service_instancia.list_orders(
          auth.user_id ?? 1,
          current_role: auth.current_role ?? 'cliente',
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('no has hecho pedidos aun'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('pedido #${item.order_id}'),
                  subtitle: Text('estado: ${item.order_status} - total: €${item.order_total}'),
                  trailing: Icon(
                    Icons.circle,
                    color: item.order_status == 'entregado' ? Colors.green : Colors.orange
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}