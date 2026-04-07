import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/historial_service.dart';
import '../../models/order_model.dart';
import '../../models/producto.dart';
import '../../models/alergeno_model.dart';
import '../../models/cart_manager.dart';
import '../../providers/auth_provider.dart';
import '../screens_client/producto_detalle_screen.dart';

/// muestra la lista de compras pasadas del cliente y gestiona la accion de repetir
/// evalua la disponibilidad del backend sin borrar lo que ya haya en el carrito
class historial_screen extends StatefulWidget {
  const historial_screen({super.key});

  @override
  State<historial_screen> createState() => _historial_screen_state();
}

class _historial_screen_state extends State<historial_screen> {
  final _service = historial_service();
  late Future<List<historial_pedido>> _pedidos_future;
  bool _loading_repetir = false;
  // IDs de pedidos cuya tarjeta está expandida para ver el desglose de productos
  final Set<int> _expandidos = {};

  @override
  void initState() {
    super.initState();
    _cargar_historial();
  }

  /// lanza la peticion al servicio para descargar la lista de pedidos del usuario
  void _cargar_historial() {
    final auth = Provider.of<auth_provider>(context, listen: false);
    setState(() {
      _pedidos_future = _service.get_historial(
        auth.user_id ?? 1,
        auth.current_role ?? 'cliente',
      );
    });
  }

  /// alterna la expansion de la tarjeta del pedido para mostrar u ocultar el desglose
  void _toggle_expansion(int pedido_id) {
    setState(() {
      if (_expandidos.contains(pedido_id)) {
        _expandidos.remove(pedido_id);
      } else {
        _expandidos.add(pedido_id);
      }
    });
  }

  /// construye un objeto producto minimo para navegar a su pantalla de detalle
  /// la pantalla de detalle cargara los ingredientes completos desde el backend
  producto _producto_desde_historial(historial_producto p) {
    return producto(
      producto_id:          p.producto_id,
      producto_nombre:      p.nombre,
      producto_precio_unitario: p.precio_unitario,
      producto_categoria:   '',
      unidades_disponibles: 0,
      disponible:           false,
      alergenos:            [],
    );
  }

  /// inyecta los productos viables directamente en la cesta global de la app
  /// respeta la cantidad original del pedido llamando add_item tantas veces como unidades habia
  ///
  /// args:
  ///   disponibles (List<dynamic>): lista de productos que han superado el filtro de stock
  ///   loc (AppLocalizations): diccionario de idiomas activo para los mensajes
  void _anadir_al_carrito(List<dynamic> disponibles, AppLocalizations loc) {
    for (var prod in disponibles) {
      final int cantidad = (prod['cantidad'] as num).toInt();
      for (int i = 0; i < cantidad; i++) {
        cart_manager.add_item(
          prod['producto_id'],
          prod['nombre'],
          double.parse(prod['precio_unitario'].toString()),
        );
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.hist_snack_added(disponibles.length.toString())),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// coordina la accion principal del boton repetir analizando la respuesta del backend
  ///
  /// args:
  ///   pedido_id (int): el numero de ticket original a clonar
  ///   loc (AppLocalizations): diccionario de idiomas activo
  Future<void> _procesar_repeticion(int pedido_id, AppLocalizations loc) async {
    setState(() => _loading_repetir = true);
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final response = await _service.repetir_pedido(
        pedido_id,
        auth.user_id ?? 1,
        auth.current_role ?? 'cliente'
      );

      final List<dynamic> disponibles = response['productos_disponibles'] ?? [];
      final List<dynamic> no_disponibles = response['productos_no_disponibles'] ?? [];

      if (!mounted) return;

      if (disponibles.isEmpty) {
        // caso c: no hay nada disponible
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(loc.hist_dialog_none_avail_title),
            content: Text(loc.hist_dialog_none_avail_desc),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ok')),
            ],
          ),
        );
      } else if (no_disponibles.isNotEmpty) {
        // caso b: faltan cosas
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(loc.hist_dialog_some_unavail_title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...no_disponibles.map((p) => Text('- ${p['nombre']}: ${p['motivo']}', style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 16),
                Text(loc.hist_dialog_some_unavail_desc),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.ord_det_cancel)),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _anadir_al_carrito(disponibles, loc);
                },
                child: Text(loc.hist_btn_add_avail),
              ),
            ],
          ),
        );
      } else {
        // caso a: todo limpio y con stock
        _anadir_al_carrito(disponibles, loc);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading_repetir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.hist_title),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<historial_pedido>>(
            future: _pedidos_future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(loc.hist_empty));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  final expandido = _expandidos.contains(item.pedido_id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // cabecera del pedido — pulsar para expandir el desglose
                          InkWell(
                            onTap: () => _toggle_expansion(item.pedido_id),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${loc.ord_det_order}${item.pedido_id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Row(
                                  children: [
                                    Chip(label: Text(item.estado, style: const TextStyle(fontSize: 12))),
                                    Icon(expandido ? Icons.expand_less : Icons.expand_more),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // fecha del pedido
                          Text(
                            '${item.fecha.day.toString().padLeft(2,'0')}/${item.fecha.month.toString().padLeft(2,'0')}/${item.fecha.year}  ${item.fecha.hour.toString().padLeft(2,'0')}:${item.fecha.minute.toString().padLeft(2,'0')}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),

                          // desglose de productos — visible solo cuando la tarjeta esta expandida
                          if (expandido) ...[
                            const Divider(),
                            ...item.productos.map((p) => InkWell(
                              // al pulsar en un producto navega a su detalle con ingredientes
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => producto_detalle_screen(item: _producto_desde_historial(p))),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.restaurant, size: 14, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text('${p.cantidad}x ${p.nombre}', style: const TextStyle(fontSize: 14))),
                                          // indicacion de que se puede pulsar para ver ingredientes
                                          const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                                        ],
                                      ),
                                    ),
                                    Text('€${(p.precio_unitario * p.cantidad).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            )).toList(),
                            const Divider(),
                          ] else ...[
                            // resumen colapsado
                            Text('${item.productos.length} ${loc.ord_det_products_title}', style: const TextStyle(color: Colors.grey)),
                            const Divider(),
                          ],

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${loc.ord_det_total}${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ElevatedButton.icon(
                                onPressed: () => _procesar_repeticion(item.pedido_id, loc),
                                icon: const Icon(Icons.replay),
                                label: Text(loc.hist_btn_repeat),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // capa de carga semitransparente que bloquea la pantalla mientras procesa la repeticion
          if (_loading_repetir)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}