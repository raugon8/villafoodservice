import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/order_staff_service.dart';
import '../../models/order_staff_model.dart';
import '../../providers/auth_provider.dart';
import 'order_detail_screen.dart';

class order_list_screen extends StatefulWidget {
  const order_list_screen({super.key});
  @override
  State<order_list_screen> createState() => _order_list_screen_state();
}

class _order_list_screen_state extends State<order_list_screen> {
  final service_instancia = order_staff_service();
  final search_controller = TextEditingController();

  String current_service = 'restaurante';

  List<order_staff_item> orders = [];
  String? selected_status;
  bool loading = true;
  String? error;
  Timer? refresh_timer;

  final List<String> status_options = ['Todos', 'pendiente', 'en_preparacion', 'listo'];
  final List<String> service_options = ['cafeteria', 'restaurante', 'reposteria'];

  @override
  void initState() {
    super.initState();
    _load_orders();
    refresh_timer = Timer.periodic(const Duration(seconds: 30), (_) => _load_orders());
  }

  @override
  void dispose() {
    refresh_timer?.cancel();
    search_controller.dispose();
    super.dispose();
  }

  Future<void> _load_orders() async {
    setState(() { loading = true; error = null; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final result = await service_instancia.list_staff_orders(
        current_service,
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'dependiente',
        status: selected_status,
        search: search_controller.text.isEmpty ? null : search_controller.text,
      );
      setState(() { orders = result; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pedidos - $current_service'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load_orders, tooltip: 'Actualizar')
        ],
      ),
      body: Column(
        children: [
          // Selector de servicio
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: DropdownButtonFormField<String>(
              value: current_service,
              decoration: InputDecoration(
                labelText: 'Servicio',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: service_options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {
                setState(() { current_service = v!; });
                _load_orders();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: TextField(
              controller: search_controller,
              decoration: InputDecoration(
                hintText: 'buscar por nº pedido o cliente',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (_) => _load_orders(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButtonFormField<String>(
              value: selected_status ?? 'Todos',
              decoration: InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: status_options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {
                setState(() { selected_status = v == 'Todos' ? null : v; });
                _load_orders();
              },
            ),
          ),
          Expanded(
            child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                ? Center(child: Text('error: $error'))
                : orders.isEmpty
                  ? const Center(child: Text('no hay pedidos'))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final item = orders[index];
                        final color = Color(order_staff_item.getStatusColor(item.order_status));
                        return Card(
                          color: item.is_new ? Colors.yellow[50] : null,
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Text('#${item.order_id}',
                                style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            title: Row(
                              children: [
                                Text(item.user_name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (item.is_new) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(4)
                                    ),
                                    child: const Text('NUEVO', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  )
                                ]
                              ],
                            ),
                            subtitle: Text(
                              '${item.order_status} · ${item.items_count} productos · €${item.order_total.toStringAsFixed(2)}'
                            ),
                            trailing: Chip(
                              label: Text(item.order_status,
                                style: const TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: color,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => order_detail_screen(
                                  order_id: item.order_id,
                                  service: current_service,
                                )
                              )
                            ).then((_) => _load_orders()),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}