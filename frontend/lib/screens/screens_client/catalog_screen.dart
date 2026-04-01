import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
// --- Idiomas ---
import '../../l10n/app_localizations.dart'; 
import '../../providers/locale_provider.dart';
// ---------------
import '../../providers/auth_provider.dart';
import '../../services/producto_service.dart';
import '../../models/producto.dart';
import '../../models/cart_manager.dart';
import 'producto_detalle_screen.dart'; 

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
  DateTime? _last_search;

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
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
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
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    // Generamos las opciones de orden usando el idioma actual
    final Map<String, String> _sort_options = {
      'name_asc': loc.sort_nombre_az,
      'name_desc': loc.sort_nombre_za,
      'price_asc': loc.sort_precio_asc,
      'price_desc': loc.sort_precio_desc,
      'availability': loc.sort_disponibles,
      'popularity': loc.sort_vendidos,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.catalogo_titulo),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: loc.catalogo_ordenar,
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
            child: Semantics(
              label: 'campo de busqueda de productos',
              textField: true,
              child: TextField(
                controller: _search_controller,
                onChanged: _on_search_changed,
                decoration: InputDecoration(
                  hintText: loc.catalogo_buscar,
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
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['Todas', 'Cafetería', 'Restaurante', 'Repostería'].map((cat) {
                // Si la categoría es 'Todas', mostramos su traducción, sino la mostramos tal cual (regla del backend)
                final cat_display = cat == 'Todas' ? loc.catalogo_todas : cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat_display),
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
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _buscar,
                            icon: const Icon(Icons.refresh),
                            label: Text(loc.boton_reintentar),
                          )
                        ],
                      ),
                    ),
                  )
                : _productos.isEmpty
                  ? Center(child: Text(loc.catalogo_sin_resultados, style: const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) => _build_producto_card(_productos[index], loc),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _build_producto_card(producto p, AppLocalizations loc) {
    final bool tiene_alergenos = p.alergenos.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.image_url != null && p.image_url!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: p.image_url!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => _placeholder_imagen(),
            )
          else
            _placeholder_imagen(),
            
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => producto_detalle_screen(item: p)));
            },
            title: Row(
              children: [
                Expanded(child: Text(p.producto_nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (tiene_alergenos)
                  const Tooltip(message: 'contiene alergenos', child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.producto_descripcion != null && p.producto_descripcion!.isNotEmpty)
                  Text(p.producto_descripcion!, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('€${p.producto_precio_unitario.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(p.producto_categoria, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(p.disponible ? '${p.unidades_disponibles} ${loc.catalogo_uds}' : loc.catalogo_sin_stock,
                      style: TextStyle(color: p.disponible ? Colors.blue : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            trailing: p.disponible
              ? IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                  onPressed: () {
                    cart_manager.add_item(p.producto_id, p.producto_nombre, p.producto_precio_unitario);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${p.producto_nombre} ${loc.catalogo_anadido}'), duration: const Duration(seconds: 1), backgroundColor: Colors.green),
                    );
                  },
                )
              : const Icon(Icons.remove_shopping_cart, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _placeholder_imagen() {
    return Container(height: 100, width: double.infinity, color: Colors.grey.shade200, child: const Icon(Icons.restaurant, size: 40, color: Colors.grey));
  }
}