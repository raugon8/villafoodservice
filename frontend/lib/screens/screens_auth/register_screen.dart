import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';
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
  bool _loading = false;

  /// extrae un mensaje legible del error de validacion de contrasena del backend
  /// el backend devuelve un json de pydantic con campos type, msg, etc.
  String _mensaje_error_amigable(dynamic error) {
    final texto = error.toString();
    // errores de validacion de contrasena
    if (texto.contains('al menos 8 caracteres')) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    if (texto.contains('al menos un número')) {
      return 'La contraseña debe contener al menos un número.';
    }
    if (texto.contains('al menos una letra mayúscula')) {
      return 'La contraseña debe contener al menos una letra mayúscula.';
    }
    if (texto.contains('al menos una letra minúscula')) {
      return 'La contraseña debe contener al menos una letra minúscula.';
    }
    if (texto.contains('ya está registrado') || texto.contains('correo')) {
      return 'Este correo ya está registrado. Prueba con otro o inicia sesión.';
    }
    return 'No se pudo crear la cuenta. Revisa los datos e inténtalo de nuevo.';
  }

  void enviar_formulario() async {
    final loc = AppLocalizations.of(context)!;
    if (user_controller.text.isEmpty || email_controller.text.isEmpty || pass_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.reg_faltan_datos)));
      return;
    }
    setState(() => _loading = true);
    try {
      final u = await service_instancia.register(user_controller.text, email_controller.text, pass_controller.text);
      if (!mounted) return;
      // mostramos dialogo de exito y volvemos al login
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('¡Cuenta creada!'),
          content: Text('Bienvenido, ${u.nombre_usuario}. Ya puedes iniciar sesión.'),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // mostramos dialogo amigable en lugar de snackbar con texto tecnico
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
          title: const Text('No se pudo crear la cuenta'),
          content: Text(_mensaje_error_amigable(e), textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.reg_titulo),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: user_controller, decoration: InputDecoration(labelText: loc.reg_nombre)),
            TextField(controller: email_controller, decoration: InputDecoration(labelText: loc.reg_email)),
            // indicacion de requisitos de contrasena para orientar al usuario antes de enviar
            TextField(
              controller: pass_controller,
              decoration: InputDecoration(
                labelText: loc.reg_pass,
                helperText: 'Mínimo 8 caracteres, una mayúscula y un número',
                helperMaxLines: 2,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: enviar_formulario, child: Text(loc.reg_crear)),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.reg_atras)),
          ],
        ),
      ),
    );
  }
}