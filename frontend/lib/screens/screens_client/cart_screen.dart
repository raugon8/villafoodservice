import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> _confirmar_pedido() async {
    if (cart_manager.items.isEmpty) return;
    final auth = Provider.of<auth_provider>(context, listen: false);
    setState(() => _loading = true);

    try {
      final pedido = await _order_service.create_order(
        cart_manager.items,
        _notas_ctrl.text,
        auth.user_id ?? 0,
        current_role: auth.current_role ?? 'cliente',
      );
      cart_manager.clear();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Pedido confirmado!'),
          content: Text(
            'Pedido #${pedido.order_id}\nTotal: €${pedido.order_total.toStringAsFixed(2)}\nEstado: ${pedido.order_status}'
          ),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu carrito'),
        actions: [
          if (cart_manager.items.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => cart_manager.clear()),
              child: const Text('Vaciar', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cart_manager.items.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('El carrito está vacío', style: TextStyle(color: Colors.grey)),
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
                        title: Text(item.product_name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('€${item.product_price.toStringAsFixed(2)} / ud'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _cambiar_cantidad(item, -1),
                            ),
                            Text('${item.quantity}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _cambiar_cantidad(item, 1),
                            ),
                            SizedBox(
                              width: 64,
                              child: Text(
                                '€${(item.product_price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
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
                  decoration: const InputDecoration(
                    labelText: 'Notas del pedido (opcional)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
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
                          Text('${cart_manager.total_items} productos',
                            style: const TextStyle(color: Colors.grey)),
                          Text('Total: €${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _confirmar_pedido,
                      icon: _loading
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle),
                      label: const Text('Confirmar pedido'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}