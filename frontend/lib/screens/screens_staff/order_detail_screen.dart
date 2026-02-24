import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/order_staff_service.dart';
import '../../models/order_staff_model.dart';
import '../../providers/auth_provider.dart';

class order_detail_screen extends StatefulWidget {
  final int order_id;
  final String service;

  const order_detail_screen({
    super.key,
    required this.order_id,
    required this.service
  });

  @override
  State<order_detail_screen> createState() => _order_detail_screen_state();
}

class _order_detail_screen_state extends State<order_detail_screen> {
  final service_instancia = order_staff_service();
  order_staff_item? order;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load_detail();
  }

  Future<void> _load_detail() async {
    setState(() { loading = true; error = null; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final result = await service_instancia.get_staff_order_detail(
        widget.order_id,
        widget.service,
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'dependiente',
      );
      setState(() { order = result; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> _change_status(String new_status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar cambio'),
        content: Text('¿Cambiar estado a "$new_status"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final updated = await service_instancia.update_order_status(
        widget.order_id,
        new_status,
        widget.service,
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'dependiente',
      );
      setState(() { order = updated; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "$new_status"'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
      );
    }
  }

  Widget _status_button() {
    if (order == null) return const SizedBox();
    switch (order!.order_status) {
      case 'pendiente':
        return ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Iniciar preparación'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => _change_status('en_preparacion'),
        );
      case 'en_preparacion':
        return ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Marcar como listo'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => _change_status('listo'),
        );
      case 'listo':
        return const Chip(
          label: Text('Pedido completado', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('pedido #${widget.order_id}')),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Text('error: $error'))
          : order == null
            ? const Center(child: Text('pedido no encontrado'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cliente: ${order!.user_name}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Chip(
                                  label: Text(order!.order_status,
                                    style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Color(order_staff_item.getStatusColor(order!.order_status)),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Pedido: ${order!.order_date_time.toString().substring(0, 16)}'),
                            if (order!.order_pickup_time != null)
                              Text('Recogida: ${order!.order_pickup_time.toString().substring(0, 16)}'),
                            Text('Total: €${order!.order_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    if (order!.order_notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.amber[50],
                        child: ListTile(
                          leading: const Icon(Icons.info_outline, color: Colors.orange),
                          title: const Text('Notas del cliente'),
                          subtitle: Text(order!.order_notes),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text('Productos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ...order!.details.map((d) => Card(
                      child: ListTile(
                        title: Text(d.product_name),
                        subtitle: Text('cantidad: ${d.detail_quantity}'),
                        trailing: Text('€${d.detail_subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
                    const SizedBox(height: 16),
                    Center(child: _status_button()),
                  ],
                ),
              ),
    );
  }
}