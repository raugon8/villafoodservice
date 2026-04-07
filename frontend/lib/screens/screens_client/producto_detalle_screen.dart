import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../models/producto.dart';
import '../../models/producto_ingrediente.dart';
import '../../models/cart_manager.dart';
import '../../services/producto_service.dart';

class producto_detalle_screen extends StatefulWidget {
  final producto item;

  const producto_detalle_screen({super.key, required this.item});

  @override
  State<producto_detalle_screen> createState() => _producto_detalle_screen_state();
}

class _producto_detalle_screen_state extends State<producto_detalle_screen> {
  final _service = producto_service();
  List<producto_ingrediente> _ingredientes = [];
  bool _loading_ingredientes = true;

  @override
  void initState() {
    super.initState();
    _cargar_ingredientes();
  }

  /// carga los ingredientes del producto desde el backend para mostrarselos al cliente
  Future<void> _cargar_ingredientes() async {
    try {
      final lista = await _service.get_ingredientes_producto(widget.item.producto_id);
      setState(() { _ingredientes = lista; _loading_ingredientes = false; });
    } catch (_) {
      // si falla la carga de ingredientes no bloqueamos la pantalla
      setState(() => _loading_ingredientes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.producto_nombre),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: widget.item.image_url != null
                ? CachedNetworkImage(
                    imageUrl: widget.item.image_url!,
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
                          widget.item.producto_nombre,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '€${widget.item.producto_precio_unitario.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.producto_categoria,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (widget.item.producto_descripcion != null && widget.item.producto_descripcion!.isNotEmpty) ...[
                    Text(widget.item.producto_descripcion!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                  ],

                  // seccion de ingredientes — se carga del backend al abrir la pantalla
                  Text(loc.det_alergenos_tit.replaceAll('lérgenos', 'ngredientes'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_loading_ingredientes)
                    const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  else if (_ingredientes.isEmpty)
                    Text('Sin ingredientes declarados', style: TextStyle(color: Colors.grey.shade600, fontSize: 14))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _ingredientes.map((ing) => Chip(
                        label: Text(
                          ing.unidad_medida != null
                            ? '${ing.ingrediente_nombre} (${ing.cantidad_necesaria.toStringAsFixed(ing.cantidad_necesaria.truncateToDouble() == ing.cantidad_necesaria ? 0 : 1)} ${ing.unidad_medida})'
                            : ing.ingrediente_nombre,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue.shade50,
                        avatar: const Icon(Icons.kitchen, size: 14, color: Colors.blue),
                      )).toList(),
                    ),

                  const SizedBox(height: 24),

                  Text(loc.det_alergenos_tit, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (widget.item.alergenos.isEmpty)
                    Text(loc.det_sin_alergenos, style: const TextStyle(color: Colors.green, fontSize: 16))
                  else
                    Wrap(
                      spacing: 8,
                      children: widget.item.alergenos.map((a) => Chip(
                        label: Text(a.nombre, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.orange,
                        avatar: const Icon(Icons.warning, color: Colors.white, size: 16),
                      )).toList(),
                    ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.item.disponible ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                      onPressed: widget.item.disponible ? () {
                        cart_manager.add_item(widget.item.producto_id, widget.item.producto_nombre, widget.item.producto_precio_unitario);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.item.producto_nombre} ${loc.catalogo_anadido}'), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      } : null,
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: Text(widget.item.disponible ? loc.det_add_carrito : loc.det_agotado, style: const TextStyle(color: Colors.white, fontSize: 18)),
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