import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/historial_service.dart';
import '../../models/order_model.dart';
import '../../models/cart_manager.dart';
import '../../providers/auth_provider.dart';

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
          double.parse(prod['precio_unitario'].toString()),  // ← así
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${loc.ord_det_order}${item.pedido_id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Chip(label: Text(item.estado, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // lista de productos resumida
                          Text('${item.productos.length} ${loc.ord_det_products_title}', style: const TextStyle(color: Colors.grey)),
                          const Divider(),
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