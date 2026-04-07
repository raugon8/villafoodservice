import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';
import '../../../services/ingrediente_service.dart';
import '../../../models/ingrediente.dart';
import '../../../providers/auth_provider.dart';
import 'ingrediente_form_screen.dart';

class ingredientes_list_screen extends StatefulWidget {
  const ingredientes_list_screen({super.key});

  @override
  State<ingredientes_list_screen> createState() => _ingredientes_list_screen_state();
}

class _ingredientes_list_screen_state extends State<ingredientes_list_screen> {
  final service_instancia = ingrediente_service();
  late Future<List<ingrediente>> _future_ingredientes;

  @override
  void initState() {
    super.initState();
    // carga ingredientes al entrar
    _cargar();
  }

  void _cargar() {
    final auth = Provider.of<auth_provider>(context, listen: false);
    setState(() {
      // ENVIAMOS EL TOKEN EN LUGAR DE USER_ID Y ROLE
      _future_ingredientes = service_instancia.get_ingredientes(
        token: auth.access_token, 
      );
    });
  }

  // devuelve el color del badge segun stock
  Color obtener_color_estado(String estado) {
    if (estado == 'crítico' || estado == 'critico') return Colors.red;
    if (estado == 'bajo') return Colors.orange;
    return Colors.green;
  }

  // modal de seguridad antes de borrar
  Future<void> _confirmar_eliminar(ingrediente item, AppLocalizations loc) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.ing_list_delete_title),
        content: Text('${loc.ing_list_delete_msg} "${item.ingrediente_nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cat_cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.ing_list_delete_msg, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        final auth = Provider.of<auth_provider>(context, listen: false);
        // ENVIAMOS EL TOKEN PARA ELIMINAR
        await service_instancia.delete_ingrediente(
          item.ingrediente_id, 
          token: auth.access_token!
        );
        _cargar();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.ing_list_deleted)));
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
        title: Text(loc.ing_list_title),
        actions: [
          // selector de idiomas
          IconButton(icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)), onPressed: () => locale_prov.toggle_locale()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(context, MaterialPageRoute(builder: (c) => const ingrediente_form_screen()));
          if (resultado == true) _cargar();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ingrediente>>(
        future: _future_ingredientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(loc.ing_list_empty));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(item.ingrediente_nombre),
                  subtitle: Text('${loc.ing_list_stock}${item.ingrediente_stock_actual}, ${loc.ing_list_weight}${item.ingrediente_unidad_medida}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(label: Text(item.estado_stock.toUpperCase()), backgroundColor: obtener_color_estado(item.estado_stock)),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final resultado = await Navigator.push(context, MaterialPageRoute(builder: (_) => ingrediente_form_screen(ingrediente_editar: item)));
                          if (resultado == true) _cargar();
                        },
                      ),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmar_eliminar(item, loc)),
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