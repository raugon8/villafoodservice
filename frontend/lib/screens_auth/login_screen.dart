import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'register_screen.dart';

class login_screen extends StatefulWidget {
  const login_screen({super.key});
  @override
  State<login_screen> createState() => _login_screen_state();
}

class _login_screen_state extends State<login_screen> {
  final email_controller = TextEditingController();
  final pass_controller = TextEditingController();
  final service_instancia = api_service();

  // ejecuta el proceso de login
  void ejecutar_login() async {
    // frena si faltan datos
    if (email_controller.text.isEmpty || pass_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('error: rellena todo')));
      return;
    }
    try {
      final u = await service_instancia.login(email_controller.text, pass_controller.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('bienvenido ${u.nombre_usuario}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: email_controller, decoration: const InputDecoration(labelText: 'email')),
            TextField(controller: pass_controller, decoration: const InputDecoration(labelText: 'pass'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: ejecutar_login, child: const Text('entrar')),
            TextButton(
              // va a pantalla registro
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const register_screen())),
              child: const Text('¿no tienes cuenta? registrate'),
            ),
          ],
        ),
      ),
    );
  }
}