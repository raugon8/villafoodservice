import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';

class cart_screen extends StatefulWidget {
  const cart_screen({super.key});
  @override
  State<cart_screen> createState() => _cart_screen_state();
}

class _cart_screen_state extends State<cart_screen> {
  final service_instancia = order_service();
  final notas_controller = TextEditingController();
  
  // lista temporal de productos añadidos
  List<cart_item> carrito = [
    cart_item(producto_id: 1, producto_nombre: 'cafe con leche', producto_precio: 1.20, cantidad: 2),
  ];

  void confirmar_pedido() async {
    try {
      final nuevo_pedido = await service_instancia.create_order(carrito, notas_controller.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('pedido #${nuevo_pedido.pedido_id} confirmado'))
      );
      Navigator.pop(context); // vuelve al home tras exito
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('error al procesar pedido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('tu carrito')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final item = carrito[index];
                return ListTile(
                  title: Text(item.producto_nombre),
                  subtitle: Text('cantidad: ${item.cantidad}'),
                  trailing: Text('€${(item.producto_precio * item.cantidad).toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(controller: notas_controller, decoration: const InputDecoration(labelText: 'notas del pedido')),
          ),
          ElevatedButton(onPressed: confirmar_pedido, child: const Text('confirmar pedido'))
        ],
      ),
    );
  }
}