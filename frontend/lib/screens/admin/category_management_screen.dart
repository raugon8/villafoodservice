import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';

class category_management_screen extends StatefulWidget {
  const category_management_screen({super.key});

  @override
  State<category_management_screen> createState() => _category_management_screen_state();
}

class _category_management_screen_state extends State<category_management_screen> {
  final _service = category_service();
  List<category_model> _categorias = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.list_categories(active_only: false);
      setState(() { _categorias = result; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _mostrar_dialogo({category_model? categoria}) async {
    final auth = Provider.of<auth_provider>(context, listen: false);
    final nombre_ctrl = TextEditingController(text: categoria?.category_name ?? '');
    final desc_ctrl = TextEditingController(text: categoria?.category_description ?? '');

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(categoria == null ? 'Nueva categoría' : 'Editar categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombre_ctrl,
              decoration: const InputDecoration(labelText: 'Nombre *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: desc_ctrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (confirmado != true) return;
    if (nombre_ctrl.text.trim().isEmpty) return;

    try {
      if (categoria == null) {
        await _service.create_category(
          nombre_ctrl.text.trim(),
          desc_ctrl.text.trim().isEmpty ? null : desc_ctrl.text.trim(),
          user_id: auth.user_id ?? 0,
          current_role: auth.current_role ?? 'admin',
        );
      } else {
        await _service.update_category(
          categoria.category_id,
          name: nombre_ctrl.text.trim(),
          description: desc_ctrl.text.trim().isEmpty ? null : desc_ctrl.text.trim(),
          user_id: auth.user_id ?? 0,
          current_role: auth.current_role ?? 'admin',
        );
      }
      _cargar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleActivo(category_model cat) async {
    final auth = Provider.of<auth_provider>(context, listen: false);
    try {
      if (cat.category_active) {
        await _service.deactivate_category(
          cat.category_id,
          user_id: auth.user_id ?? 0,
          current_role: auth.current_role ?? 'admin',
        );
      } else {
        await _service.update_category(
          cat.category_id,
          active: true,
          user_id: auth.user_id ?? 0,
          current_role: auth.current_role ?? 'admin',
        );
      }
      _cargar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Categorías'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrar_dialogo(),
        child: const Icon(Icons.add),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
          : _categorias.isEmpty
            ? const Center(child: Text('No hay categorías'))
            : ListView.builder(
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.category_active ? Colors.green : Colors.grey,
                      child: Text(cat.category_name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(cat.category_name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cat.category_active ? null : Colors.grey,
                      )),
                    subtitle: cat.category_description != null
                      ? Text(cat.category_description!)
                      : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrar_dialogo(categoria: cat),
                        ),
                        IconButton(
                          icon: Icon(
                            cat.category_active ? Icons.toggle_on : Icons.toggle_off,
                            color: cat.category_active ? Colors.green : Colors.grey,
                            size: 32,
                          ),
                          onPressed: () => _toggleActivo(cat),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}