import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// --- Idiomas ---
import '../../../l10n/app_localizations.dart'; 
import '../../../providers/locale_provider.dart';
// ---------------
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
  late Future<List<order>> _pedidos_future;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _cargar_pedidos());
  }

  void _cargar_pedidos() {
    final auth = Provider.of<auth_provider>(context, listen: false);
    setState(() {
      _pedidos_future = service_instancia.list_orders(
        auth.user_id ?? 1,
        current_role: auth.current_role ?? 'cliente',
      );
    });
  }

  Color _get_status_color(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':      return Colors.green;
      case 'en_preparacion': return const Color(0xFF2196F3);
      case 'listo':          return Colors.lightGreen;
      case 'cancelado':      return Colors.red;
      default:               return Colors.orange; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.pedidos_titulo),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
        ],
      ),
      body: FutureBuilder<List<order>>(
        future: _pedidos_future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
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
                      onPressed: _cargar_pedidos,
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.boton_reintentar),
                    )
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(loc.pedidos_vacio));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Semantics(
                label: 'pedido numero ${item.order_id}, estado: ${item.order_status}, total: ${item.order_total} euros',
                child: ExcludeSemantics(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('${loc.pedidos_numero}${item.order_id}'),
                      subtitle: Text('${loc.pedidos_estado} ${item.order_status} - ${loc.pedidos_total} €${item.order_total}'),
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