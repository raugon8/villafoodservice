import 'package:flutter/material.dart';
import '../../models/producto_ingrediente.dart';
import '../../models/ingrediente.dart';
import '../../services/producto_service.dart';
import '../../services/ingrediente_service.dart';

class producto_ingredientes_screen extends StatefulWidget {
  final int producto_id;
  final String nombre_producto;

  const producto_ingredientes_screen({
    super.key,
    required this.producto_id,
    required this.nombre_producto,
  });

  @override
  State<producto_ingredientes_screen> createState() => _producto_ingredientes_screen_state();
}

class _producto_ingredientes_screen_state extends State<producto_ingredientes_screen> {
  final _prod_service = producto_service();
  final _ing_service = ingrediente_service();
  late Future<List<producto_ingrediente>> _future_ingredientes;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _future_ingredientes = _prod_service.get_ingredientes_producto(widget.producto_id);
    });
  }

  Future<void> _mostrar_dialogo_agregar() async {
    List<ingrediente> disponibles = [];
    ingrediente? seleccionado;
    final cantidad_ctrl = TextEditingController(text: '1.0');

    try {
      disponibles = await _ing_service.get_ingredientes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ingredientes: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, set_dialog_state) {
            return AlertDialog(
              title: const Text('Agregar ingrediente'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ingrediente>(
                    decoration: const InputDecoration(
                      labelText: 'Ingrediente',
                      border: OutlineInputBorder(),
                    ),
                    items: disponibles.map((ing) {
                      return DropdownMenuItem(
                        value: ing,
                        child: Text('${ing.ingrediente_nombre} (${ing.ingrediente_unidad_medida})'),
                      );
                    }).toList(),
                    onChanged: (val) => set_dialog_state(() => seleccionado = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cantidad_ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad necesaria',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: seleccionado == null
                      ? null
                      : () async {
                          final cantidad = double.tryParse(cantidad_ctrl.text.trim());
                          if (cantidad == null || cantidad <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Cantidad inválida')),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          try {
                            await _prod_service.agregar_ingrediente(
                              widget.producto_id,
                              seleccionado!.ingrediente_id,
                              cantidad,
                            );
                            _cargar();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ingrediente agregado')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    cantidad_ctrl.dispose();
  }

  Future<void> _confirmar_quitar(producto_ingrediente item, int total) async {
    if (total <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: mínimo un ingrediente')),
      );
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar ingrediente'),
        content: Text('¿Quitar "${item.ingrediente_nombre}" de este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quitar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _prod_service.quitar_ingrediente(widget.producto_id, item.ingrediente_id);
        _cargar();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrediente quitado')),
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
      appBar: AppBar(title: Text('Ingredientes de ${widget.nombre_producto}')),
      body: FutureBuilder<List<producto_ingrediente>>(
        future: _future_ingredientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Sin ingredientes asignados'));
          }

          final lista = snapshot.data!;
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = lista[index];
              return ListTile(
                title: Text(item.ingrediente_nombre),
                subtitle: Text(
                  'necesario: ${item.cantidad_necesaria}'
                  '${item.unidad_medida != null ? " ${item.unidad_medida}" : ""}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmar_quitar(item, lista.length),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrar_dialogo_agregar,
        tooltip: 'Agregar ingrediente',
        child: const Icon(Icons.add_link),
      ),
    );
  }
}