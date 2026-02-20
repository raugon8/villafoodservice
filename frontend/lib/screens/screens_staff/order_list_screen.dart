import 'package:flutter/material.dart';
import '../../../services/order_staff_service.dart';
import '../../../models/order_staff_model.dart';

class order_list_screen extends StatefulWidget {
  const order_list_screen({super.key});
  @override
  State<order_list_screen> createState() => _order_list_screen_state();
}

class _order_list_screen_state extends State<order_list_screen> {
  final service_instancia = order_staff_service();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gestion de pedidos staff')),
      body: FutureBuilder<List<order_staff_item>>(
        future: service_instancia.list_staff_orders('restaurante'), // simulamos servicio restaurante
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                // si es nuevo se pone en color amarillento
                color: item.es_nuevo ? Colors.yellow[100] : Colors.white,
                child: ListTile(
                  title: Text('pedido #${item.pedido_id} - ${item.usuario_nombre}'),
                  subtitle: Text('estado: ${item.pedido_estado} | total: €${item.pedido_total}'),
                  trailing: item.es_nuevo ? const Chip(label: Text('NUEVO'), backgroundColor: Colors.orange) : null,
                  onTap: () {
                    // confirmacion para cambiar estado
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('iniciando preparacion...')));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}