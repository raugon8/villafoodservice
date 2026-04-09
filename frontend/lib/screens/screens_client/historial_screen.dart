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

// lista con todos los tickets viejos del usuario
class historial_screen extends StatefulWidget {
  const historial_screen({super.key});

  @override
  State<historial_screen> createState() => _historial_screen_state();
}

class _historial_screen_state extends State<historial_screen> {
  final _service = historial_service();
  late Future<List<historial_pedido>> _pedidos_future;
  bool _loading_repetir = false;
  
  // llevamos la cuenta de que tickets hemos desplegado
  final Set<int> _expandidos = {};

  @override
  void initState() {
    super.initState();
    _cargar_historial();
  }

  // preguntamos a la base de datos por los pedidos de este usuario
  void _cargar_historial() {
    final auth = Provider.of<auth_provider>(context, listen: false);
    setState(() {
      _pedidos_future = _service.get_historial(
        auth.user_id ?? 1,
        auth.current_role ?? 'cliente',
      );
    });
  }

  // abre o cierra el acordeon de los productos
  void _toggle_expansion(int pedido_id) {
    setState(() {
      if (_expandidos.contains(pedido_id)) {
        _expandidos.remove(pedido_id);
      } else {
        _expandidos.add(pedido_id);
      }
    });
  }

  // devuelve el color correspondiente al estado del pedido — misma paleta que el panel de staff
  Color _color_estado(String estado) {
    switch (estado) {
      case 'pendiente':      return const Color(0xFFFFC107); // amarillo
      case 'en_preparacion': return const Color(0xFF2196F3); // azul
      case 'listo':          return const Color(0xFF4CAF50); // verde
      case 'entregado':      return const Color(0xFF009688); // teal
      case 'cancelado':      return const Color(0xFFF44336); // rojo
      default:               return const Color(0xFF9E9E9E); // gris
    }
  }

  // creamos un producto fantasma rapido para poder abrir su pantalla de detalle
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

  // mete de golpe en la cesta todo lo que nos confirme el backend que tiene stock
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

  // avisa al backend de que queremos clonar un pedido
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
        // nos rebotaron todo
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
        // nos rebotaron cosas sueltas
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
        // luz verde a todo
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

  // le dice al backend que el cliente ya recogió el pedido y recarga el historial
  Future<void> _marcar_entregado(int pedido_id, AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar recogida'),
        content: const Text('¿Confirmas que ya has recogido este pedido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.ord_det_cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, lo recogí')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      await _service.marcar_entregado(
        pedido_id,
        auth.user_id ?? 1,
        auth.current_role ?? 'cliente',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido marcado como recogido'), backgroundColor: Colors.green),
      );
      // recargamos el historial para que se vea el nuevo estado
      _cargar_historial();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error: $e'), backgroundColor: Colors.red),
        );
      }
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
          // boton super claro para recargar sin tener que arrastrar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar pedidos',
            onPressed: () {
              _cargar_historial();
            },
          ),
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // lo dejamos tb por si la gente ya esta acostumbrada a tirar pa abajo
          RefreshIndicator(
            onRefresh: () async {
              _cargar_historial();
              await _pedidos_future;
            },
            child: FutureBuilder<List<historial_pedido>>(
              future: _pedidos_future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(child: Text('error: ${snapshot.error}', style: const TextStyle(color: Colors.red))),
                      )
                    ]
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(child: Text(loc.hist_empty)),
                      )
                    ]
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    final expandido = _expandidos.contains(item.pedido_id);
                    final cancelado = item.estado == 'cancelado';
                    final listo = item.estado == 'listo';
                    
                    // el front busca el campo en el objeto item
                    final bool tieneNotas = item.cancel_reason != null && item.cancel_reason!.isNotEmpty;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      // lo pitamos de rojo si murio el pedido
                      shape: cancelado
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.red, width: 1.5),
                          )
                        : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _toggle_expansion(item.pedido_id),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${loc.ord_det_order}${item.pedido_id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(item.estado, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                        backgroundColor: _color_estado(item.estado),
                                      ),
                                      Icon(expandido ? Icons.expand_less : Icons.expand_more),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.fecha.day.toString().padLeft(2,'0')}/${item.fecha.month.toString().padLeft(2,'0')}/${item.fecha.year}  ${item.fecha.hour.toString().padLeft(2,'0')}:${item.fecha.minute.toString().padLeft(2,'0')}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            
                            // esto funciona siempre y cuando order_model.dart haya leido el json bien
                            if (tieneNotas) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cancelado ? Colors.red.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: cancelado ? Colors.red.shade200 : Colors.orange.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(cancelado ? Icons.cancel_outlined : Icons.info_outline, color: cancelado ? Colors.red : Colors.orange, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Nota del pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: cancelado ? Colors.red : Colors.orange.shade800)),
                                          Text(item.cancel_reason!, style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),

                            // lista de productos
                            if (expandido) ...[
                              const Divider(),
                              ...item.productos.map((p) => InkWell(
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
                              Text('${item.productos.length} ${loc.ord_det_products_title}', style: const TextStyle(color: Colors.grey)),
                              const Divider(),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${loc.ord_det_total}${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                // cuando esta listo ponemos los botones en columna para que no se salgan de la card
                                if (listo)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _marcar_entregado(item.pedido_id, loc),
                                        icon: const Icon(Icons.check_circle_outline),
                                        label: const Text('Ya lo recogí'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      ),
                                      const SizedBox(height: 6),
                                      ElevatedButton.icon(
                                        onPressed: () => _procesar_repeticion(item.pedido_id, loc),
                                        icon: const Icon(Icons.replay),
                                        label: Text(loc.hist_btn_repeat),
                                      ),
                                    ],
                                  )
                                else if (!cancelado)
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
          ),

          // pantallita negra de carga
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