import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';
import '../../../providers/auth_provider.dart';
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
  bool loading = false;

  void ejecutar_login() async {
    if (email_controller.text.isEmpty || pass_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('error: rellena todo'))
      );
      return;
    }

    setState(() { loading = true; });

    try {
      final u = await service_instancia.login(
        email_controller.text, pass_controller.text
      );

      // get roles from backend
      final roles_response = await service_instancia.get_user_roles(u.usuario_id);
      final List<String> roles = List<String>.from(roles_response);

      // save user and roles in global state
      if (!mounted) return;
      Provider.of<auth_provider>(context, listen: false).set_user(u.usuario_id, roles);

      // navigate based on number of roles
      if (roles.length > 1) {
        Navigator.pushReplacementNamed(context, '/role_selector');
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
      );
    } finally {
      setState(() { loading = false; });
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
            TextField(
              controller: email_controller,
              decoration: const InputDecoration(labelText: 'email')
            ),
            TextField(
              controller: pass_controller,
              decoration: const InputDecoration(labelText: 'pass'),
              obscureText: true
            ),
            const SizedBox(height: 20),
            loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: ejecutar_login,
                  child: const Text('entrar')
                ),
            TextButton(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (c) => const register_screen())
              ),
              child: const Text('¿no tienes cuenta? registrate'),
            ),
          ],
        ),
      ),
    );
  }
}