import 'package:flutter/material.dart';
import '../../services/producto_service.dart';
import '../../models/producto.dart';
import '../screens_productos/producto_ingredientes_screen.dart';
class productos_list_screen extends StatefulWidget {
  const productos_list_screen({super.key});
  @override
  State<productos_list_screen> createState() => _productos_list_screen_state();
}

class _productos_list_screen_state extends State<productos_list_screen> {
  final service_instancia = producto_service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gestion de productos')),
      body: FutureBuilder<List<producto>>(
        future: service_instancia.get_productos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('no hay productos'));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: ListTile(
                  
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (c) => producto_ingredientes_screen(nombre_producto: item.producto_nombre)
                    ));
                  },
                  title: Text(item.producto_nombre),
                  subtitle: Text('${item.producto_categoria} | €${item.producto_precio_unitario}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('stock: ${item.unidades_disponibles}'),
                      Icon(Icons.circle, color: item.disponible ? Colors.green : Colors.red, size: 15),
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