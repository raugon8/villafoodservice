import 'package:flutter/material.dart';
import '../../services/ingrediente_service.dart';
import '../../models/ingrediente.dart';
import '../screens_ingredientes/ingrediente_form_screen.dart';

class ingredientes_list_screen extends StatefulWidget {
  const ingredientes_list_screen({super.key});
  @override
  State<ingredientes_list_screen> createState() => _ingredientes_list_screen_state();
}

class _ingredientes_list_screen_state extends State<ingredientes_list_screen> {
  final service_instancia = ingrediente_service();

  // elige el color del badge segun stock
  Color obtener_color_estado(String estado) {
    if (estado == 'crítico') return Colors.red;
    if (estado == 'bajo') return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gestion de ingredientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ingrediente_form_screen())),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ingrediente>>(
        future: service_instancia.get_ingredientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('no hay ingredientes'));
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(item.ingrediente_nombre),
                  subtitle: Text('stock: ${item.ingrediente_stock_actual} ${item.ingrediente_unidad_medida}'),
                  trailing: Chip(
                    label: Text(item.estado_stock.toUpperCase()),
                    backgroundColor: obtener_color_estado(item.estado_stock),
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