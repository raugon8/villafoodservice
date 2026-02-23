import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class register_screen extends StatefulWidget {
  const register_screen({super.key});
  @override
  State<register_screen> createState() => _register_screen_state();
}

class _register_screen_state extends State<register_screen> {
  final user_controller = TextEditingController();
  final email_controller = TextEditingController();
  final pass_controller = TextEditingController();
  final service_instancia = api_service();

  // manda el registro al backend
  void enviar_formulario() async {
    if (user_controller.text.isEmpty || email_controller.text.isEmpty || pass_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('faltan datos')));
      return;
    }
    try {
      final u = await service_instancia.register(user_controller.text, email_controller.text, pass_controller.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('creado: ${u.nombre_usuario}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('registro')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: user_controller, decoration: const InputDecoration(labelText: 'nombre')),
            TextField(controller: email_controller, decoration: const InputDecoration(labelText: 'email')),
            TextField(controller: pass_controller, decoration: const InputDecoration(labelText: 'pass'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: enviar_formulario, child: const Text('crear')),
            // vuelve atras en la pila de navegacion
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('atras')),
          ],
        ),
      ),
    );
  }
}