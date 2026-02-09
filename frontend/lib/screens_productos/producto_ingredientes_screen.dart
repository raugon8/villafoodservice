import 'package:flutter/material.dart';
import '../../models/producto_ingrediente.dart';

class producto_ingredientes_screen extends StatefulWidget {
  final String nombre_producto;
  const producto_ingredientes_screen({super.key, required this.nombre_producto});

  @override
  State<producto_ingredientes_screen> createState() => _producto_ingredientes_screen_state();
}

class _producto_ingredientes_screen_state extends State<producto_ingredientes_screen> {
  // lista simulada de ingredientes asignados al producto
  List<producto_ingrediente> ingredientes_actuales = [
    producto_ingrediente(ingrediente_id: 1, ingrediente_nombre: 'jamon', cantidad_necesaria: 0.05, unidad_medida: 'kg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ingredientes de ${widget.nombre_producto}')),
      body: ListView.builder(
        itemCount: ingredientes_actuales.length,
        itemBuilder: (context, index) {
          final item = ingredientes_actuales[index];
          return ListTile(
            title: Text(item.ingrediente_nombre),
            subtitle: Text('necesario: ${item.cantidad_necesaria} ${item.unidad_medida}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // validacion: no se puede quitar el ultimo ingrediente
                if (ingredientes_actuales.length <= 1) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('error: minimo un ingrediente')));
                } else {
                  setState(() => ingredientes_actuales.removeAt(index));
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // aqui abririas un dialogo para elegir nuevos ingredientes
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('simulacion: elegir ingrediente')));
        },
        child: const Icon(Icons.add_link),
      ),
    );
  }
}