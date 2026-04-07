import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart'; 
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/producto_service.dart';
import '../../services/category_service.dart';
import '../../models/producto.dart';
import '../../models/category_model.dart';
import '../../models/cart_manager.dart';
import 'producto_detalle_screen.dart'; 
import 'cart_screen.dart';

class catalog_screen extends StatefulWidget {
  const catalog_screen({super.key});

  @override
  State<catalog_screen> createState() => _catalog_screen_state();
}

class _catalog_screen_state extends State<catalog_screen> {
  final _service = producto_service();
  final _category_service = category_service();
  final _search_controller = TextEditingController();

  List<producto> _productos = [];
  List<category_model> _categorias = [];
  Set<int> _category_ids_seleccionados = {};
  bool _loading = false;
  String? _error;

  String _categoria_seleccionada = 'Todas';
  String _sort_by = 'name_asc';
  DateTime? _last_search;

  @override
  void initState() {
    super.initState();
    _cargar_categorias();
    _buscar();
  }

  Future<void> _cargar_categorias() async {
    try {
      final cats = await _category_service.list_categories(active_only: true);
      setState(() => _categorias = cats);
    } catch (_) {}
  }

  Future<void> _buscar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final results = await _service.search_products(
        token: auth.access_token ?? '', // PASAMOS EL TOKEN
        query: _search_controller.text.isEmpty ? null : _search_controller.text,
        service: _categoria_seleccionada == 'Todas' ? null : _categoria_seleccionada,
        category_ids: _category_ids_seleccionados.isEmpty ? null : _category_ids_seleccionados.toList(),
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

  void _toggle_category(int category_id) {
    setState(() {
      if (_category_ids_seleccionados.contains(category_id)) {
        _category_ids_seleccionados.remove(category_id);
      } else {
        _category_ids_seleccionados.add(category_id);
      }
    });
    _buscar();
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
    final isDesktop = MediaQuery.of(context).size.width > 800;

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
            icon: const Icon(Icons.shopping_cart),
            tooltip: loc.home_btn_carrito,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const cart_screen())),
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: -8, 
              children: ['Todas', 'Cafetería', 'Restaurante', 'Repostería'].map((cat) {
                final cat_display = cat == 'Todas' ? loc.catalogo_todas : cat;
                return FilterChip(
                  label: Text(cat_display),
                  selected: _categoria_seleccionada == cat,
                  onSelected: (_) { setState(() => _categoria_seleccionada = cat); _buscar(); },
                );
              }).toList(),
            ),
          ),
          if (_categorias.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: -8,
                children: _categorias.map((cat) {
                  final seleccionada = _category_ids_seleccionados.contains(cat.category_id);
                  return FilterChip(
                    label: Text(cat.category_name),
                    selected: seleccionada,
                    onSelected: (_) => _toggle_category(cat.category_id),
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
                  : isDesktop
                      ? GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _productos.length,
                          itemBuilder: (context, index) => _build_producto_card(_productos[index], loc),
                        )
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.image_url != null && p.image_url!.isNotEmpty)
            SizedBox(
              width: 120,
              height: 120,
              child: CachedNetworkImage(
                imageUrl: p.image_url!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => _placeholder_imagen(),
              ),
            )
          else
            SizedBox(
              width: 120,
              height: 120,
              child: _placeholder_imagen(),
            ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => producto_detalle_screen(item: p)));
              },
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      p.producto_nombre, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ),
                  if (tiene_alergenos)
                    const Tooltip(message: 'Contiene alérgenos', child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20)),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (p.producto_descripcion != null && p.producto_descripcion!.isNotEmpty)
                    Text(
                      p.producto_descripcion!, 
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('€${p.producto_precio_unitario.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(p.producto_categoria, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 10)),
                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _placeholder_imagen() {
    return Container(
      color: Colors.grey.shade200, 
      child: const Center(child: Icon(Icons.restaurant, size: 40, color: Colors.grey))
    );
  }
}