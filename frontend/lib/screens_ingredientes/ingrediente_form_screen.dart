import 'package:flutter/material.dart';
import '../../services/ingrediente_service.dart';

class ingrediente_form_screen extends StatefulWidget {
  const ingrediente_form_screen({super.key});
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
  final service_instancia = ingrediente_service();

  // envia el nuevo ingrediente al backend
  void guardar() async {
    if (form_key.currentState!.validate()) {
      try {
        await service_instancia.create_ingrediente({
          'ingrediente_nombre': nombre_controller.text,
          'ingrediente_stock_actual': double.parse(stock_actual_controller.text),
          'ingrediente_stock_minimo': double.parse(stock_minimo_controller.text),
          'ingrediente_unidad_medida': unidad_seleccionada,
          'ingrediente_precio_unitario': double.parse(precio_controller.text),
        });
        Navigator.pop(context); // vuelve al listado tras exito
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('nuevo ingrediente')),
      body: Form(
        key: form_key,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(controller: nombre_controller, decoration: const InputDecoration(labelText: 'nombre')),
            TextFormField(controller: stock_actual_controller, decoration: const InputDecoration(labelText: 'stock actual'), keyboardType: TextInputType.number),
            TextFormField(controller: stock_minimo_controller, decoration: const InputDecoration(labelText: 'stock minimo'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: unidad_seleccionada,
              items: ['kg', 'g', 'L', 'ml', 'unidades'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => unidad_seleccionada = v!),
              decoration: const InputDecoration(labelText: 'unidad de medida'),
            ),
            TextFormField(controller: precio_controller, decoration: const InputDecoration(labelText: 'precio unitario'), keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: guardar, child: const Text('guardar')),
          ],
        ),
      ),
    );
  }
}