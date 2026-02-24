import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_manager.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';

class cart_screen extends StatefulWidget {
  const cart_screen({super.key});
  @override
  State<cart_screen> createState() => _cart_screen_state();
}

class _cart_screen_state extends State<cart_screen> {
  final service_instancia = order_service();
  final notas_controller = TextEditingController();

  void confirmar_pedido() async {
    if (cart_manager.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('el carrito está vacío'))
      );
      return;
    }
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final nuevo_pedido = await service_instancia.create_order(
        List.from(cart_manager.items),
        notas_controller.text,
        auth.user_id ?? 1,
        current_role: auth.current_role ?? 'cliente',
      );
      cart_manager.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('pedido #${nuevo_pedido.order_id} confirmado'))
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error al procesar pedido: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = cart_manager.items;
    final total = carrito.fold(0.0, (sum, i) => sum + (i.product_price * i.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('tu carrito')),
      body: carrito.isEmpty
        ? const Center(child: Text('no hay productos en el carrito'))
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: carrito.length,
                  itemBuilder: (context, index) {
                    final item = carrito[index];
                    return ListTile(
                      title: Text(item.product_name),
                      subtitle: Text('cantidad: ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('€${(item.product_price * item.quantity).toStringAsFixed(2)}'),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                } else {
                                  cart_manager.items.removeAt(index);
                                }
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('€${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: notas_controller,
                  decoration: const InputDecoration(labelText: 'notas del pedido')
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: confirmar_pedido,
                  child: const Text('confirmar pedido')
                ),
              )
            ],
          ),
    );
  }
}