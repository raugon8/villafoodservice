import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../models/producto_ingrediente.dart';
import '../../models/ingrediente.dart';
import '../../services/producto_service.dart';
import '../../services/ingrediente_service.dart';
import '../../providers/auth_provider.dart';

/// pantalla para gestionar los ingredientes que componen un producto
/// se usa para controlar la receta y descontar stock automaticamente
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

  /// solicita al backend la lista de ingredientes de este producto concreto
  void _cargar() {
    setState(() {
      _future_ingredientes = _prod_service.get_ingredientes_producto(widget.producto_id);
    });
  }

  /// abre un modal para seleccionar un ingrediente del almacen y asignar la cantidad
  ///
  /// args:
  ///   loc (AppLocalizations): diccionario de traduccion activo
  Future<void> _mostrar_dialogo_agregar(AppLocalizations loc) async {
    final auth = Provider.of<auth_provider>(context, listen: false);
    final user_id = auth.user_id!;
    final current_role = auth.current_role!;

    List<ingrediente> disponibles = [];
    ingrediente? seleccionado;
    final cantidad_ctrl = TextEditingController(text: '1.0');

    try {
      disponibles = await _ing_service.get_ingredientes(user_id: user_id, current_role: current_role);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error: $e'), backgroundColor: Colors.red));
      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, set_dialog_state) {
            return AlertDialog(
              title: Text(loc.prod_ing_add_title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ingrediente>(
                    decoration: InputDecoration(labelText: loc.prod_ing_ing_label, border: const OutlineInputBorder()),
                    items: disponibles.map((ing) => DropdownMenuItem(value: ing, child: Text('${ing.ingrediente_nombre} (${ing.ingrediente_unidad_medida})'))).toList(),
                    onChanged: (val) => set_dialog_state(() => seleccionado = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cantidad_ctrl,
                    decoration: InputDecoration(labelText: loc.prod_ing_qty_label, border: const OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.prod_ing_btn_cancel)),
                ElevatedButton(
                  onPressed: seleccionado == null
                      ? null
                      : () async {
                          final cantidad = double.tryParse(cantidad_ctrl.text.trim());
                          if (cantidad == null || cantidad <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.prod_ing_err_qty)));
                            return;
                          }
                          Navigator.pop(ctx);
                          try {
                            await _prod_service.agregar_ingrediente(widget.producto_id, seleccionado!.ingrediente_id, cantidad, user_id: user_id, current_role: current_role);
                            _cargar();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.prod_ing_msg_added)));
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error: $e'), backgroundColor: Colors.red));
                          }
                        },
                  child: Text(loc.prod_ing_btn_add),
                ),
              ],
            );
          },
        );
      },
    );
    cantidad_ctrl.dispose();
  }

  /// muestra aviso de seguridad y borra el ingrediente de la receta del producto
  ///
  /// args:
  ///   item (producto_ingrediente): objeto del ingrediente a borrar
  ///   total (int): conteo total actual para evitar dejar receta a cero
  ///   loc (AppLocalizations): diccionario de traducciones
  Future<void> _confirmar_quitar(producto_ingrediente item, int total, AppLocalizations loc) async {
    if (total <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.prod_ing_err_min)));
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.prod_ing_del_title),
        content: Text(loc.prod_ing_del_msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.prod_ing_btn_cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.prod_ing_btn_del, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmado == true) {
      final auth = Provider.of<auth_provider>(context, listen: false);
      try {
        await _prod_service.quitar_ingrediente(widget.producto_id, item.ingrediente_id, user_id: auth.user_id!, current_role: auth.current_role!);
        _cargar();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.prod_ing_msg_del)));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error: $e'), backgroundColor: Colors.red));
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
        title: Text('${loc.prod_ing_title}${widget.nombre_producto}'),
        actions: [
          IconButton(icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)), onPressed: () => locale_prov.toggle_locale()),
        ],
      ),
      body: FutureBuilder<List<producto_ingrediente>>(
        future: _future_ingredientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(loc.prod_ing_empty));

          final lista = snapshot.data!;
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = lista[index];
              return ListTile(
                title: Text(item.ingrediente_nombre),
                subtitle: Text('${loc.prod_ing_needed}${item.cantidad_necesaria}${item.unidad_medida != null ? " ${item.unidad_medida}" : ""}'),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmar_quitar(item, lista.length, loc)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrar_dialogo_agregar(loc),
        tooltip: loc.prod_ing_add_tooltip,
        child: const Icon(Icons.add_link),
      ),
    );
  }
}