import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';
import '../../services/ingrediente_service.dart';
import '../../models/ingrediente.dart';
import '../../providers/auth_provider.dart';

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
    // rellena los datos si estamos editando
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

  // procesa el formulario hacia el backend
  void guardar(AppLocalizations loc) async {
    if (!form_key.currentState!.validate()) return;
    setState(() => _is_loading = true);

    final auth = Provider.of<auth_provider>(context, listen: false);
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
          token: auth.access_token! // ENVIAMOS EL TOKEN AQUÍ
        );
      } else {
        await service_instancia.create_ingrediente(
          datos, 
          token: auth.access_token! // ENVIAMOS EL TOKEN AQUÍ
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_es_edicion ? loc.ing_form_updated : loc.ing_form_created)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _is_loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(_es_edicion ? loc.ing_form_edit : loc.ing_form_new),
        actions: [
          // bandera de idiomas obligatoria segun requisitos
          IconButton(icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)), onPressed: () => locale_prov.toggle_locale()),
        ],
      ),
      body: Form(
        key: form_key,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: nombre_controller,
              decoration: InputDecoration(labelText: loc.ing_form_name, border: const OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? loc.ing_form_name_err : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: stock_actual_controller,
              decoration: InputDecoration(labelText: loc.ing_form_stock, border: const OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => double.tryParse(v ?? '') == null ? loc.ing_form_invalid : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: stock_minimo_controller,
              decoration: InputDecoration(labelText: loc.ing_form_min_stock, border: const OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => double.tryParse(v ?? '') == null ? loc.ing_form_invalid : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: unidad_seleccionada,
              decoration: InputDecoration(labelText: loc.ing_form_unit, border: const OutlineInputBorder()),
              items: ['kg', 'g', 'L', 'ml', 'unidades'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => unidad_seleccionada = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: precio_controller,
              decoration: InputDecoration(labelText: loc.ing_form_price, border: const OutlineInputBorder(), prefixText: '€ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => double.tryParse(v ?? '') == null ? loc.ing_form_invalid : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _is_loading ? null : () => guardar(loc),
                child: _is_loading ? const CircularProgressIndicator(color: Colors.white) : Text(_es_edicion ? loc.ing_form_update : loc.cat_save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}