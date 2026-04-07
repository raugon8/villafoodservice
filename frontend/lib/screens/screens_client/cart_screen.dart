import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_manager.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';


class cart_screen extends StatefulWidget {
  const cart_screen({super.key});

  @override
  State<cart_screen> createState() => _cart_screen_state();
}

class _cart_screen_state extends State<cart_screen> {
  final _order_service = order_service();
  final _notas_ctrl = TextEditingController();
  bool _loading = false;

  double get _total => cart_manager.items.fold(
    0, (sum, i) => sum + (i.product_price * i.quantity)
  );

  void _cambiar_cantidad(cart_item item, int delta) {
    setState(() {
      item.quantity += delta;
      if (item.quantity <= 0) cart_manager.items.remove(item);
    });
  }

  /// extrae un mensaje legible del error del backend para mostrarlo al cliente
  /// el backend puede devolver un string simple o un objeto con 'message' y 'errors'
  String _mensaje_error_amigable(dynamic error) {
    final texto = error.toString().replaceAll('Exception: ', '');
    // si el backend devuelve un json con lista de errores, extraemos solo los nombres de productos
    if (texto.contains('Algunos productos no están disponibles') || texto.contains('no disponibles')) {
      return 'Algunos productos de tu carrito ya no están disponibles en la cantidad solicitada. Revisa las cantidades e inténtalo de nuevo.';
    }
    if (texto.contains('stock') || texto.contains('Stock')) {
      return 'No hay suficiente stock de alguno de los productos. Reduce la cantidad e inténtalo de nuevo.';
    }
    if (texto.contains('timeout') || texto.contains('tardado')) {
      return 'La conexión ha tardado demasiado. Comprueba tu conexión a internet e inténtalo de nuevo.';
    }
    // mensaje generico amigable para errores desconocidos
    return 'No se ha podido completar el pedido. Por favor, inténtalo de nuevo en unos momentos.';
  }

  Future<void> _confirmar_pedido() async {
    final loc = AppLocalizations.of(context)!;
    if (cart_manager.items.isEmpty) return;
    final auth = Provider.of<auth_provider>(context, listen: false);
    setState(() => _loading = true);

    try {
      final pedido = await _order_service.create_order(
        cart_manager.items, _notas_ctrl.text, auth.user_id ?? 0, current_role: auth.current_role ?? 'cliente',
      );
      cart_manager.clear();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(loc.cart_confirmado_tit),
          content: Text(
            '${loc.pedidos_numero}${pedido.order_id}\n${loc.pedidos_total} €${pedido.order_total.toStringAsFixed(2)}\n${loc.pedidos_estado} ${pedido.order_status}'
          ),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: Text(loc.cart_aceptar),
            ),
          ],
        ),
      );
    } catch (e) {
      // mostramos un dialogo amigable en lugar de un snackbar con texto tecnico
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
          title: const Text('No se pudo realizar el pedido'),
          content: Text(_mensaje_error_amigable(e), textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.carrito_titulo),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
          if (cart_manager.items.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => cart_manager.clear()),
              child: Text(loc.cart_vaciar, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cart_manager.items.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(loc.carrito_vacio, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart_manager.items.length,
                  itemBuilder: (context, index) {
                    final item = cart_manager.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.product_name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('€${item.product_price.toStringAsFixed(2)} ${loc.cart_ud}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _cambiar_cantidad(item, -1)),
                            Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _cambiar_cantidad(item, 1)),
                            SizedBox(
                              width: 64,
                              child: Text('€${(item.product_price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _notas_ctrl,
                  decoration: InputDecoration(
                    labelText: loc.cart_notas,
                    prefixIcon: const Icon(Icons.note),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${cart_manager.total_items} ${loc.cart_productos_count}', style: const TextStyle(color: Colors.grey)),
                          Text('${loc.pedidos_total} €${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _confirmar_pedido,
                      icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle),
                      label: Text(loc.carrito_confirmar),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}