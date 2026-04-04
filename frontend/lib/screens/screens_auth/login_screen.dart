import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../screens_home/home_screen.dart';
import '../../widgets/text_scale_toggle.dart';
import 'register_screen.dart';

// pantalla de acceso al sistema con diseño centrado y accesible
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

  // gestiona la autenticacion y guarda los datos en el provider
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

      final roles_response = await service_instancia.get_user_roles(u.usuario_id);
      final List<String> roles = List<String>.from(roles_response);

      if (!mounted) return;
      
      Provider.of<auth_provider>(context, listen: false).set_user(u.usuario_id, roles);

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const home_screen())
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('villafood'),
        centerTitle: true,
        actions: const [text_scale_toggle()],
      ),
      // centra el contenido y permite scroll para el teclado
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // icono decorativo de la app
                  Icon(Icons.restaurant, size: 64, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 24),
                  
                  Semantics(
                    label: 'campo de correo electronico',
                    child: TextField(
                      controller: email_controller,
                      decoration: const InputDecoration(
                        labelText: 'email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      )
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Semantics(
                    label: 'campo de contraseña',
                    child: TextField(
                      controller: pass_controller,
                      decoration: const InputDecoration(
                        labelText: 'contraseña',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  loading
                    ? const CircularProgressIndicator()
                    : Semantics(
                        label: 'boton para iniciar sesion',
                        button: true,
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: ejecutar_login,
                            child: const Text('entrar', style: TextStyle(fontSize: 16))
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  
                  TextButton(
                    onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (c) => const register_screen())
                    ),
                    child: const Text('¿no tienes cuenta? registrate', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}