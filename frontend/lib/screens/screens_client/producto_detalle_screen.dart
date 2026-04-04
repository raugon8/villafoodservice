import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/producto.dart';
import '../../models/cart_manager.dart';

// pantalla de detalles ampliados para el cliente
class producto_detalle_screen extends StatelessWidget {
  final producto item;

  const producto_detalle_screen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.producto_nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagen destacada superior
            SizedBox(
              width: double.infinity,
              height: 250,
              child: item.image_url != null
                ? CachedNetworkImage(
                    imageUrl: item.image_url!,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (c, u, e) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant, size: 100, color: Colors.grey),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.producto_nombre,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '€${item.producto_precio_unitario.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.producto_categoria,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  if (item.producto_descripcion != null && item.producto_descripcion!.isNotEmpty) ...[
                    Text(item.producto_descripcion!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                  ],

                  // seccion de alergenos requerida por la tarea
                  const Text('Alérgenos declarados:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  if (item.alergenos.isEmpty)
                    const Text('Sin alérgenos declarados', style: TextStyle(color: Colors.green, fontSize: 16))
                  else
                    Wrap(
                      spacing: 8,
                      children: item.alergenos.map((a) => Chip(
                        label: Text(a.nombre, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.orange,
                        avatar: const Icon(Icons.warning, color: Colors.white, size: 16),
                      )).toList(),
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // boton de añadir al carrito
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.disponible ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                      onPressed: item.disponible ? () {
                        cart_manager.add_item(item.producto_id, item.producto_nombre, item.producto_precio_unitario);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.producto_nombre} añadido al carrito'), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      } : null,
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: Text(item.disponible ? 'Añadir al carrito' : 'Agotado', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}