import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/producto.dart';
import '../../models/alergeno_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/producto_service.dart';
import '../../services/api_service.dart';
import '../../services/image_upload_service.dart';

class producto_form_screen extends StatefulWidget {
  final producto? producto_editar;
  const producto_form_screen({super.key, this.producto_editar});

  @override
  State<producto_form_screen> createState() => _producto_form_screen_state();
}

class _producto_form_screen_state extends State<producto_form_screen> {
  final _form_key = GlobalKey<FormState>();
  final _nombre_ctrl = TextEditingController();
  final _precio_ctrl = TextEditingController();
  final _descripcion_ctrl = TextEditingController();
  String _categoria_sel = 'Cafetería';
  bool _is_loading = false;
  
  // variables nuevas para imagenes y alergenos
  String? _image_url;
  List<alergeno> _todos_alergenos = [];
  List<int> _alergenos_seleccionados = [];

  final List<String> _categorias = ['Cafetería', 'Restaurante', 'Repostería'];
  final _service = producto_service();
  final _api = api_service();
  final _upload_service = image_upload_service();

  bool get _es_edicion => widget.producto_editar != null;

  @override
  void initState() {
    super.initState();
    _cargar_alergenos();
    if (_es_edicion) {
      final p = widget.producto_editar!;
      _nombre_ctrl.text = p.producto_nombre;
      _precio_ctrl.text = p.producto_precio_unitario.toString();
      _descripcion_ctrl.text = p.producto_descripcion ?? '';
      _categoria_sel = p.producto_categoria;
      _image_url = p.image_url;
      _alergenos_seleccionados = p.alergenos.map((a) => a.id).toList();
    }
  }

  // simulamos la carga de alergenos del backend
  Future<void> _cargar_alergenos() async {
    final lista = await _api.get_alergenos_mock();
    setState(() {
      _todos_alergenos = lista;
    });
  }

  // lanza el selector de imagenes simulado
  Future<void> _subir_imagen() async {
    setState(() => _is_loading = true);
    final url = await _upload_service.upload_image();
    if (url != null) {
      setState(() => _image_url = url);
    }
    setState(() => _is_loading = false);
  }

  @override
  void dispose() {
    _nombre_ctrl.dispose();
    _precio_ctrl.dispose();
    _descripcion_ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form_key.currentState!.validate()) return;
    setState(() => _is_loading = true);

    final auth = Provider.of<auth_provider>(context, listen: false);

    try {
      final datos = {
        'producto_nombre': _nombre_ctrl.text.trim(),
        'producto_precioUnitario': double.parse(_precio_ctrl.text.trim()),
        'producto_categoria': _categoria_sel,
        'producto_descripcion': _descripcion_ctrl.text.trim(),
        'image_url': _image_url,
        'alergeno_ids': _alergenos_seleccionados,
      };

      if (_es_edicion) {
        await _service.update_producto(
          widget.producto_editar!.producto_id,
          datos,
          user_id: auth.user_id!,
          current_role: auth.current_role!,
        );
      } else {
        await _service.create_producto(
          datos,
          user_id: auth.user_id!,
          current_role: auth.current_role!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_es_edicion ? 'Producto actualizado' : 'Producto creado')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _is_loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_es_edicion ? 'Editar Producto' : 'Nuevo Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form_key,
          child: ListView(
            children: [
              // seccion de imagen
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _image_url != null
                        ? CachedNetworkImage(
                            imageUrl: _image_url!,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                          )
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _is_loading ? null : _subir_imagen,
                      icon: const Icon(Icons.upload),
                      label: const Text('Cambiar imagen'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nombre_ctrl,
                decoration: const InputDecoration(labelText: 'Nombre del producto', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precio_ctrl,
                decoration: const InputDecoration(labelText: 'Precio unitario', border: OutlineInputBorder(), prefixText: '€ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un precio';
                  final precio = double.tryParse(v.trim());
                  if (precio == null || precio <= 0) return 'Precio inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoria_sel,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _categoria_sel = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcion_ctrl,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // seccion de alergenos
              const Text('Alérgenos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (_todos_alergenos.isEmpty) const CircularProgressIndicator()
              else Wrap(
                spacing: 8,
                children: _todos_alergenos.map((alergeno) {
                  final seleccionado = _alergenos_seleccionados.contains(alergeno.id);
                  return FilterChip(
                    label: Text(alergeno.nombre),
                    selected: seleccionado,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _alergenos_seleccionados.add(alergeno.id);
                        } else {
                          _alergenos_seleccionados.remove(alergeno.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _is_loading ? null : _guardar,
                  child: _is_loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_es_edicion ? 'Actualizar' : 'Crear Producto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}