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
  late Future<List<order>> _pedidos_future;

  @override
  void initState() {
    super.initState();
    // usamos future.microtask para asegurarnos de que el provider este listo
    Future.microtask(() => _cargar_pedidos());
  }

  // aislamos la carga para poder reintentarla si falla el internet
  void _cargar_pedidos() {
    final auth = Provider.of<auth_provider>(context, listen: false);
    setState(() {
      _pedidos_future = service_instancia.list_orders(
        auth.user_id ?? 1,
        current_role: auth.current_role ?? 'cliente',
      );
    });
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('mis pedidos')),
      body: FutureBuilder<List<order>>(
        future: _pedidos_future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // bloque de error de red con boton de reintento (tarea 16)
            final error_msg = snapshot.error.toString().replaceAll('Exception: ', '');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(error_msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _cargar_pedidos, // reintenta la carga
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            );
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