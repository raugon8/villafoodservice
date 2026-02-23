import 'package:flutter/material.dart';
import '../../services/ingrediente_service.dart';
import '../../models/ingrediente.dart';

class ingrediente_form_screen extends StatefulWidget {
  final ingrediente? ingrediente_editar;

  const ingrediente_form_screen({super.key, this.ingrediente_editar});

  @override
  State<ingrediente_form_screen> createState() => _ingrediente_form_screen_state();
}

class _ingrediente_form_screen_state extends State<ingrediente_form_screen> {
  final form_key = GlobalKey<FormState>();
  final nombre_controller = TextEditingController();
  final stock_actual_controller = TextEditingController();
  final stock_minimo_controller = TextEditingController();
  final precio_controller = TextEditingController();
  String unidad_seleccionada = 'kg';
  bool _is_loading = false;

  final service_instancia = ingrediente_service();

  bool get _es_edicion => widget.ingrediente_editar != null;

  @override
  void initState() {
    super.initState();
    if (_es_edicion) {
      final ing = widget.ingrediente_editar!;
      nombre_controller.text = ing.ingrediente_nombre;
      stock_actual_controller.text = ing.ingrediente_stock_actual.toString();
      stock_minimo_controller.text = ing.ingrediente_stock_minimo.toString();
      precio_controller.text = ing.ingrediente_precio_unitario.toString();
      unidad_seleccionada = ing.ingrediente_unidad_medida;
    }
  }

  @override
  void dispose() {
    nombre_controller.dispose();
    stock_actual_controller.dispose();
    stock_minimo_controller.dispose();
    precio_controller.dispose();
    super.dispose();
  }

  void guardar() async {
    if (!form_key.currentState!.validate()) return;

    setState(() => _is_loading = true);

    final datos = {
      'ingrediente_nombre': nombre_controller.text.trim(),
      'ingrediente_stockActual': double.parse(stock_actual_controller.text.trim()),
      'ingrediente_stockMinimo': double.parse(stock_minimo_controller.text.trim()),
      'ingrediente_unidadMedida': unidad_seleccionada,
      'ingrediente_precioUnitario': double.parse(precio_controller.text.trim()),
    };

    try {
      if (_es_edicion) {
        await service_instancia.update_ingrediente(
          widget.ingrediente_editar!.ingrediente_id,
          datos,
        );
      } else {
        await service_instancia.create_ingrediente(datos);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_es_edicion ? 'Ingrediente actualizado' : 'Ingrediente creado')),
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
      appBar: AppBar(
        title: Text(_es_edicion ? 'Editar ingrediente' : 'Nuevo ingrediente'),
      ),
      body: Form(
        key: form_key,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: nombre_controller,
              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: stock_actual_controller,
              decoration: const InputDecoration(labelText: 'Stock actual', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => double.tryParse(v ?? '') == null ? 'Valor inválido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: stock_minimo_controller,
              decoration: const InputDecoration(labelText: 'Stock mínimo', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => double.tryParse(v ?? '') == null ? 'Valor inválido' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: unidad_seleccionada,
              decoration: const InputDecoration(labelText: 'Unidad de medida', border: OutlineInputBorder()),
              items: ['kg', 'g', 'L', 'ml', 'unidades']
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => unidad_seleccionada = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: precio_controller,
              decoration: const InputDecoration(labelText: 'Precio unitario', border: OutlineInputBorder(), prefixText: '€ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => double.tryParse(v ?? '') == null ? 'Valor inválido' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _is_loading ? null : guardar,
                child: _is_loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_es_edicion ? 'Actualizar' : 'Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}