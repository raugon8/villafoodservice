import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/order_staff_service.dart';
import '../../models/order_staff_model.dart';
import '../../providers/auth_provider.dart';
import 'order_detail_screen.dart';

// pantalla donde el personal ve los pedidos en tiempo real
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

  // listas de estado base 
  final List<String> status_options = ['todos', 'pendiente', 'en_preparacion', 'listo'];
  final List<String> service_options = ['cafeteria', 'restaurante', 'reposteria'];

  @override
  void initState() {
    super.initState();
    _load_orders();
    // refrezco en tiempo real cada 30 segundos
    refresh_timer = Timer.periodic(const Duration(seconds: 30), (_) => _load_orders());
  }

  @override
  void dispose() {
    refresh_timer?.cancel();
    search_controller.dispose();
    super.dispose();
  }

  // baja los pedidos desde el backend aplicando los filtros de busqueda y estado
  Future<void> _load_orders() async {
    setState(() { loading = true; error = null; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final result = await service_instancia.list_staff_orders(
        current_service,
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'dependiente',
        status: selected_status == 'todos' ? null : selected_status,
        search: search_controller.text.isEmpty ? null : search_controller.text,
      );
      setState(() { orders = result; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.ord_list_title}$current_service'),
        actions: [
          // bandera obligatoria de la app
          IconButton(icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)), onPressed: () => locale_prov.toggle_locale()),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load_orders)
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: DropdownButtonFormField<String>(
              value: current_service,
              decoration: InputDecoration(
                labelText: loc.ord_list_service,
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: service_options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {
                setState(() => current_service = v!);
                _load_orders();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: TextField(
              controller: search_controller,
              decoration: InputDecoration(
                hintText: loc.ord_list_search,
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
              value: selected_status ?? 'todos',
              decoration: InputDecoration(
                labelText: loc.ord_list_status,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: status_options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {
                setState(() => selected_status = v);
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
                  ? Center(child: Text(loc.ord_list_empty))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final item = orders[index];
                        final color = Color(order_staff_item.getStatusColor(item.order_status));
                        return Card(
                          // usamos opacidad para que el fondo se adapte al modo oscuro sin deslumbrar
                          color: item.is_new ? Colors.orange.withOpacity(0.15) : null,
                          elevation: item.is_new ? 0 : 1,
                          // le ponemos un borde sutil para enmarcarlo bien
                          shape: item.is_new 
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                              )
                            : null,
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Text('#${item.order_id}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            title: Row(
                              children: [
                                Text(item.user_name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (item.is_new) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                    child: Text(loc.ord_list_new, style: const TextStyle(color: Colors.white, fontSize: 10)),
                                  )
                                ]
                              ],
                            ),
                            subtitle: Text('${item.order_status} · ${item.items_count} ${loc.ord_list_products} · €${item.order_total.toStringAsFixed(2)}'),
                            trailing: Chip(label: Text(item.order_status, style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: color),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => order_detail_screen(order_id: item.order_id, service: current_service))).then((_) => _load_orders()),
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