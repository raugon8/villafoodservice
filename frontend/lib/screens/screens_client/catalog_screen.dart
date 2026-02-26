import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/producto_service.dart';
import '../../models/producto.dart';

class catalog_screen extends StatefulWidget {
  const catalog_screen({super.key});

  @override
  State<catalog_screen> createState() => _catalog_screen_state();
}

class _catalog_screen_state extends State<catalog_screen> {
  final _service = producto_service();
  final _search_controller = TextEditingController();

  List<producto> _productos = [];
  bool _loading = false;
  String? _error;

  String _categoria_seleccionada = 'Todas';
  String _sort_by = 'name_asc';

  // Debounce
  DateTime? _last_search;

  final Map<String, String> _sort_options = {
    'name_asc': 'Nombre A-Z',
    'name_desc': 'Nombre Z-A',
    'price_asc': 'Precio menor-mayor',
    'price_desc': 'Precio mayor-menor',
    'availability': 'Disponibles primero',
    'popularity': 'Más vendidos',
  };

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  Future<void> _buscar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final results = await _service.search_products(
        user_id: auth.user_id ?? 0,
        current_role: auth.current_role ?? 'cliente',
        query: _search_controller.text.isEmpty ? null : _search_controller.text,
        service: _categoria_seleccionada == 'Todas' ? null : _categoria_seleccionada,
        available_only: false,
        sort_by: _sort_by,
      );
      setState(() { _productos = results; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _on_search_changed(String value) {
    _last_search = DateTime.now();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (DateTime.now().difference(_last_search!) >= const Duration(milliseconds: 300)) {
        _buscar();
      }
    });
  }

  @override
  void dispose() {
    _search_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (v) { setState(() => _sort_by = v); _buscar(); },
            itemBuilder: (_) => _sort_options.entries
              .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search_controller,
              onChanged: _on_search_changed,
              decoration: InputDecoration(
                hintText: 'Buscar producto o ingrediente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search_controller.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _search_controller.clear();
                      _buscar();
                    })
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['Todas', 'Cafetería', 'Restaurante', 'Repostería'].map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _categoria_seleccionada == cat,
                    onSelected: (_) { setState(() => _categoria_seleccionada = cat); _buscar(); },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                : _productos.isEmpty
                  ? const Center(child: Text('Sin resultados', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) => _build_producto_card(_productos[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _build_producto_card(producto p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: p.disponible ? Colors.green : Colors.grey,
          child: Icon(
            p.disponible ? Icons.check : Icons.close,
            color: Colors.white, size: 18,
          ),
        ),
        title: Text(p.producto_nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.producto_descripcion != null && p.producto_descripcion!.isNotEmpty)
              Text(p.producto_descripcion!, style: const TextStyle(fontSize: 12)),
            Row(
              children: [
                Text('€${p.producto_precio_unitario.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(p.producto_categoria,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                const SizedBox(width: 8),
                Text(p.disponible ? '${p.unidades_disponibles} uds' : 'Sin stock',
                  style: TextStyle(
                    color: p.disponible ? Colors.blue : Colors.red,
                    fontSize: 11
                  )),
              ],
            ),
          ],
        ),
        trailing: p.disponible
          ? IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
              onPressed: () {}, // TODO: añadir al carrito
            )
          : null,
      ),
    );
  }
}