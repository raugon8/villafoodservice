import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
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

  // gestiona la autenticacion y guarda los datos en el provider incluyendo el token JWT
  void ejecutar_login() async {
    if (email_controller.text.isEmpty || pass_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error_campos))
      );
      return;
    }

    setState(() { loading = true; });

    try {
      // login devuelve el usuario, los roles y el token JWT en un solo mapa
      final resultado = await service_instancia.login(
        email_controller.text, pass_controller.text
      );

      final u     = resultado['usuario'];
      final roles = resultado['roles'] as List<String>;
      final token = resultado['access_token'] as String;

      if (!mounted) return;

      // guardamos el token en el provider para que todos los services lo usen en sus headers
      Provider.of<auth_provider>(context, listen: false).set_user(
        u.usuario_id,
        roles,
        token: token,
      );

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
    final localizations = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final theme_prov = Provider.of<theme_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';
    // responsive: layout split en web, centrado en movil
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // formulario reutilizado en ambos layouts
    final formCard = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // en movil mostramos el logo arriba del formulario
            // en web el logo aparece en el panel izquierdo
            if (!isDesktop) ...[
              Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
                errorBuilder: (c, e, s) => Icon(Icons.restaurant, size: 64, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 24),
            ],
            if (isDesktop) ...[
              Text(localizations.login_titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
            ],

            Semantics(
              label: 'campo de correo electronico',
              child: TextField(
                controller: email_controller,
                decoration: InputDecoration(
                  labelText: localizations.login_email,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                )
              ),
            ),
            const SizedBox(height: 20),

            Semantics(
              label: 'campo de contraseña',
              child: TextField(
                controller: pass_controller,
                decoration: InputDecoration(
                  labelText: localizations.login_password,
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true
              ),
            ),
            const SizedBox(height: 32),

            loading
              ? const CircularProgressIndicator()
              : Semantics(
                  label: 'boton para iniciar sesion',
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: ejecutar_login,
                      child: Text(localizations.login_boton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                    ),
                  ),
                ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (c) => const register_screen())
              ),
              child: Text(localizations.login_registro, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: isDesktop ? const Text('VillaFood') : Text(localizations.login_titulo),
        centerTitle: !isDesktop,
        actions: [
          // boton modo oscuro/claro
          IconButton(
            icon: Icon(theme_prov.is_dark_mode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Modo Oscuro/Claro',
            onPressed: () => theme_prov.toggle_theme(),
          ),
          // boton de idioma
          Semantics(
            label: is_spanish ? 'Cambiar idioma a inglés' : 'Change language to Spanish',
            button: true,
            child: IconButton(
              icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
              onPressed: () => locale_prov.toggle_locale(),
            ),
          ),
          const text_scale_toggle()
        ],
      ),
      body: isDesktop
        // layout web: panel izquierdo decorativo + formulario derecha
        ? Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 160,
                        height: 160,
                        errorBuilder: (c, e, s) => Icon(Icons.restaurant_menu, size: 160, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'VillaFood Service',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: formCard,
                    ),
                  ),
                ),
              ),
            ],
          )
        // layout movil: formulario centrado con logo arriba
        : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: formCard,
              ),
            ),
          ),
    );
  }
}