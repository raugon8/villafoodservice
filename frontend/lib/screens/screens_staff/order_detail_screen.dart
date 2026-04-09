import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// importamos diccionarios
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/order_staff_service.dart';
import '../../models/order_staff_model.dart';
import '../../providers/auth_provider.dart';

// pantalla que muestra los detalles de un pedido al personal
// permite cambiar el estado del pedido (ej. de pendiente a listo)
class order_detail_screen extends StatefulWidget {
  final int order_id;
  final String service;

  const order_detail_screen({
    super.key,
    required this.order_id,
    required this.service
  });

  @override
  State<order_detail_screen> createState() => _order_detail_screen_state();
}

class _order_detail_screen_state extends State<order_detail_screen> {
  final service_instancia = order_staff_service();
  order_staff_item? order;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load_detail();
  }

  // solicita al backend los datos completos del pedido seleccionado
  Future<void> _load_detail() async {
    setState(() { loading = true; error = null; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final result = await service_instancia.get_staff_order_detail(
        widget.order_id,
        widget.service,
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'dependiente',
      );
      setState(() { order = result; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  // muestra un dialogo de confirmacion y actualiza el estado del pedido
  //
  // args:
  //   new_status: el nuevo estado que se le asignara al pedido
  //   loc: diccionario de traduccion activo
  Future<void> _change_status(String new_status, AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.ord_det_confirm_title),
        content: Text('${loc.ord_det_confirm_msg}"$new_status"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.ord_det_cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.ord_det_confirm)),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final updated = await service_instancia.update_order_status(
        widget.order_id,
        new_status,
        widget.service,
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'dependiente',
      );
      setState(() { order = updated; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.ord_det_status_updated}"$new_status"')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.ord_det_error}$e'), backgroundColor: Colors.red));
    }
  }

  // muestra un dialogo para escribir la nota de cancelacion (opcional) y cancela el pedido
  // restaura el stock de ingredientes en el backend
  Future<void> _cancelar_pedido(AppLocalizations loc) async {
    final nota_controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 40),
        title: const Text('Cancelar pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Seguro que quieres cancelar este pedido? Se restaurará el stock de ingredientes.'),
            const SizedBox(height: 16),
            TextField(
              controller: nota_controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación (opcional)',
                hintText: 'El cliente podrá ver este mensaje...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.ord_det_cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar pedido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final updated = await service_instancia.cancel_order(
        widget.order_id,
        widget.service,
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'dependiente',
        cancel_reason: nota_controller.text.trim().isEmpty ? null : nota_controller.text.trim(),
      );
      setState(() { order = updated; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cancelado y stock restaurado'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.ord_det_error}$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // dibuja el boton de accion dependiendo del estado actual del pedido
  //
  // args:
  //   loc: diccionario de traduccion activo
  Widget _status_button(AppLocalizations loc) {
    if (order == null) return const SizedBox();
    switch (order!.order_status) {
      case 'pendiente':
        return Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(loc.ord_det_btn_start),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => _change_status('en_preparacion', loc),
            ),
            const SizedBox(height: 8),
            // boton de cancelar disponible en estado pendiente
            OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Cancelar pedido', style: TextStyle(color: Colors.red)),
              onPressed: () => _cancelar_pedido(loc),
            ),
          ],
        );
      case 'en_preparacion':
        return Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: Text(loc.ord_det_btn_ready),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _change_status('listo', loc),
            ),
            const SizedBox(height: 8),
            // boton de cancelar disponible en estado en_preparacion
            OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Cancelar pedido', style: TextStyle(color: Colors.red)),
              onPressed: () => _cancelar_pedido(loc),
            ),
          ],
        );
      case 'listo':
        return Column(
          children: [
            Chip(
              label: Text(loc.ord_det_btn_completed, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 8),
            // el dependiente puede confirmar la entrega si el cliente ya recogió el pedido
            ElevatedButton.icon(
              icon: const Icon(Icons.handshake_outlined),
              label: const Text('Marcar como entregado'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => _change_status('entregado', loc),
            ),
          ],
        );
      case 'entregado':
        return Chip(
          label: const Text('Pedido entregado', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
        );
      case 'cancelado':
        return Chip(
          label: const Text('Pedido cancelado', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.ord_det_title}${widget.order_id}'),
        actions: [
          IconButton(icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)), onPressed: () => locale_prov.toggle_locale()),
        ],
      ),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Text('${loc.ord_det_error}$error'))
          : order == null
            ? Center(child: Text(loc.ord_det_not_found))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${loc.ord_det_client}${order!.user_name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Chip(
                                  label: Text(order!.order_status, style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Color(order_staff_item.getStatusColor(order!.order_status)),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${loc.ord_det_order}${order!.order_date_time.toString().substring(0, 16)}'),
                            if (order!.order_pickup_time != null)
                              Text('${loc.ord_det_pickup}${order!.order_pickup_time.toString().substring(0, 16)}'),
                            Text('${loc.ord_det_total}${order!.order_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    if (order!.order_notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      // arreglamos el color ciego usando opacidad en vez de shade
                      Card(
                        color: Colors.orange.withOpacity(0.15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.info_outline, color: Colors.orange),
                          title: Text(loc.ord_det_notes_title),
                          subtitle: Text(order!.order_notes),
                        ),
                      ),
                    ],
                    // muestra la nota de cancelacion si el pedido fue cancelado con motivo
                    if (order!.order_status == 'cancelado' && order!.cancel_reason != null && order!.cancel_reason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      // arreglamos el color ciego usando opacidad
                      Card(
                        color: Colors.red.withOpacity(0.15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                          title: const Text('Motivo de cancelación', style: TextStyle(color: Colors.red)),
                          subtitle: Text(order!.cancel_reason!),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(loc.ord_det_products_title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ...order!.details.map((d) => Card(
                      child: ListTile(
                        title: Text(d.product_name),
                        subtitle: Text('${loc.ord_det_qty}${d.detail_quantity}'),
                        trailing: Text('€${d.detail_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
                    const SizedBox(height: 16),
                    Center(child: _status_button(loc)),
                  ],
                ),
              ),
    );
  }
}