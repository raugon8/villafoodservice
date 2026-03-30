import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/order_service.dart';
import '../../../models/order_model.dart';
import '../../../providers/auth_provider.dart';

// pantalla donde el cliente visualiza su historial de pedidos
class orders_screen extends StatefulWidget {
  const orders_screen({super.key});
  @override
  State<orders_screen> createState() => _orders_screen_state();
}

class _orders_screen_state extends State<orders_screen> {
  final service_instancia = order_service();

  // asigna un color visual dependiendo del estado exacto del pedido
  Color _get_status_color(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':      return Colors.green;
      case 'en_preparacion': return const Color(0xFF2196F3); // el azul brillante que pediste
      case 'listo':          return Colors.lightGreen;
      case 'cancelado':      return Colors.red;
      default:               return Colors.orange; // para pendiente
    }
  }

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
              
              // envolvemos en semantics para que talkback lea el resumen del pedido
              return Semantics(
                label: 'pedido numero ${item.order_id}, estado: ${item.order_status}, total: ${item.order_total} euros',
                // usamos el widget excludesemantics para ocultar los textos internos al lector
                child: ExcludeSemantics(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('pedido #${item.order_id}'),
                      subtitle: Text('estado: ${item.order_status} - total: €${item.order_total}'),
                      trailing: Icon(
                        Icons.circle,
                        color: _get_status_color(item.order_status),
                      ),
                    ),
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