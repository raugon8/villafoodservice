import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/producto_service.dart';
import '../../models/producto.dart';
import '../../models/cart_manager.dart';
import '../../providers/auth_provider.dart';
import '../screens_productos/producto_ingredientes_screen.dart';
import '../screens_productos/producto_form_screen.dart';
import '../screens_client/cart_screen.dart';

class productos_list_screen extends StatefulWidget {
  const productos_list_screen({super.key});

  @override
  State<productos_list_screen> createState() => _productos_list_screen_state();
}

class _productos_list_screen_state extends State<productos_list_screen> {
  final service_instancia = producto_service();
  late Future<List<producto>> _future_productos;

  @override
  void initState() {
    super.initState();
    _cargar_productos();
  }

  void _cargar_productos() {
    setState(() {
      _future_productos = service_instancia.get_productos();
    });
  }

  Future<void> _confirmar_eliminar(BuildContext context, producto item) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${item.producto_nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final auth = Provider.of<auth_provider>(context, listen: false);
      try {
        await service_instancia.delete_producto(
          item.producto_id,
          user_id: auth.user_id!,
          current_role: auth.current_role!,
        );
        _cargar_productos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => cart_screen()),
                ).then((_) => setState(() {})),
              ),
              if (cart_manager.total_items > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart_manager.total_items}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: FutureBuilder<List<producto>>(
        future: _future_productos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => producto_ingredientes_screen(
                          producto_id: item.producto_id,
                          nombre_producto: item.producto_nombre,
                        ),
                      ),
                    ).then((_) => _cargar_productos());
                  },
                  title: Text(item.producto_nombre),
                  subtitle: Text(
                    '${item.producto_categoria} | €${item.producto_precio_unitario.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('stock: ${item.unidades_disponibles}'),
                          Icon(
                            Icons.circle,
                            color: item.disponible ? Colors.green : Colors.red,
                            size: 15,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                        onPressed: item.disponible
                            ? () {
                                cart_manager.add_item(
                                  item.producto_id,
                                  item.producto_nombre,
                                  item.producto_precio_unitario,
                                );
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${item.producto_nombre} añadido al carrito')),
                                );
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => producto_form_screen(producto_editar: item),
                            ),
                          );
                          if (resultado == true) _cargar_productos();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmar_eliminar(context, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const producto_form_screen()),
          );
          if (resultado == true) _cargar_productos();
        },
        tooltip: 'Nuevo producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}