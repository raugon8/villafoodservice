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

  void enviar_formulario() async {
    final loc = AppLocalizations.of(context)!;
    if (user_controller.text.isEmpty || email_controller.text.isEmpty || pass_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.reg_faltan_datos)));
      return;
    }
    try {
      final u = await service_instancia.register(user_controller.text, email_controller.text, pass_controller.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.reg_creado}${u.nombre_usuario}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
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
            TextField(controller: pass_controller, decoration: InputDecoration(labelText: loc.reg_pass), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: enviar_formulario, child: Text(loc.reg_crear)),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.reg_atras)),
          ],
        ),
      ),
    );
  }
}