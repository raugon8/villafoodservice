import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart'; 
import '../../providers/locale_provider.dart';
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
        // usamos el texto traducido para el error
        SnackBar(content: Text(AppLocalizations.of(context)!.error_campos))
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
    // 1. Obtenemos las traducciones de esta pantalla
    final localizations = AppLocalizations.of(context)!;
    // 2. Obtenemos el proveedor de idiomas para el botón de la bandera
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.login_titulo), // titulo traducido
        centerTitle: true,
        actions: [
          // --- BOTÓN DE IDIOMA (TAREA 17) ---
          Semantics(
            label: is_spanish ? 'Cambiar idioma a inglés' : 'Change language to Spanish',
            button: true,
            child: IconButton(
              icon: Text(
                is_spanish ? '🇪🇸' : '🇬🇧', 
                style: const TextStyle(fontSize: 24),
              ),
              onPressed: () {
                locale_prov.toggle_locale();
              },
            ),
          ),
          // ----------------------------------
          const text_scale_toggle()
        ],
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
                      decoration: InputDecoration(
                        labelText: localizations.login_email, // label traducido
                        prefixIcon: const Icon(Icons.email),
                        border: const OutlineInputBorder(),
                      )
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Semantics(
                    label: 'campo de contraseña',
                    child: TextField(
                      controller: pass_controller,
                      decoration: InputDecoration(
                        labelText: localizations.login_password, // label traducido
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
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
                            child: Text(localizations.login_boton, style: const TextStyle(fontSize: 16)) // botón traducido
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  
                  TextButton(
                    onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (c) => const register_screen())
                    ),
                    child: Text(localizations.login_registro, style: const TextStyle(color: Colors.grey, fontSize: 13)), // texto registro traducido
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