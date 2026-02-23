import 'package:flutter/material.dart';
import '../../../services/ingrediente_service.dart';
import '../../../models/ingrediente.dart';
import 'ingrediente_form_screen.dart';

class ingredientes_list_screen extends StatefulWidget {
  const ingredientes_list_screen({super.key});

  @override
  State<ingredientes_list_screen> createState() => _ingredientes_list_screen_state();
}

class _ingredientes_list_screen_state extends State<ingredientes_list_screen> {
  final service_instancia = ingrediente_service();
  late Future<List<ingrediente>> _future_ingredientes;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _future_ingredientes = service_instancia.get_ingredientes();
    });
  }

  Color obtener_color_estado(String estado) {
    if (estado == 'crítico') return Colors.red;
    if (estado == 'bajo') return Colors.orange;
    return Colors.green;
  }

  Future<void> _confirmar_eliminar(ingrediente item) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ingrediente'),
        content: Text('¿Eliminar "${item.ingrediente_nombre}"?'),
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
      try {
        await service_instancia.delete_ingrediente(item.ingrediente_id);
        _cargar();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrediente eliminado')),
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
      appBar: AppBar(title: const Text('Gestión de Ingredientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const ingrediente_form_screen()),
          );
          if (resultado == true) _cargar();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ingrediente>>(
        future: _future_ingredientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay ingredientes'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(item.ingrediente_nombre),
                  subtitle: Text('stock: ${item.ingrediente_stock_actual} ${item.ingrediente_unidad_medida}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(item.estado_stock.toUpperCase()),
                        backgroundColor: obtener_color_estado(item.estado_stock),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ingrediente_form_screen(ingrediente_editar: item),
                            ),
                          );
                          if (resultado == true) _cargar();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmar_eliminar(item),
                      ),
                    ],
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