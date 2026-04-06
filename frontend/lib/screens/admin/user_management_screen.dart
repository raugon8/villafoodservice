import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/user_service.dart';
import '../../models/role_model.dart';
import '../../providers/auth_provider.dart';

class user_management_screen extends StatefulWidget {
  const user_management_screen({super.key});
  @override
  State<user_management_screen> createState() => _user_management_screen_state();
}

class _user_management_screen_state extends State<user_management_screen> {
  final service_instancia = user_service();
  List<user_with_roles> _usuarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar_usuarios();
  }

  Future<void> _cargar_usuarios() async {
    setState(() { _loading = true; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final lista = await service_instancia.list_users(
        user_id: auth.user_id ?? 1,
        current_role: 'admin'
      );
      setState(() { _usuarios = lista; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
      );
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _abrir_formulario(AppLocalizations loc, {user_with_roles? usuario}) {
    final name_ctrl     = TextEditingController(text: usuario?.user_name ?? '');
    final email_ctrl    = TextEditingController(text: usuario?.user_email ?? '');
    final pass_ctrl     = TextEditingController();
    final List<String> roles_disponibles = ['admin', 'cliente', 'dependiente', 'almacen'];
    List<String> roles_seleccionados = List.from(usuario?.roles ?? ['cliente']);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set_state) => AlertDialog(
          title: Text(usuario == null ? loc.user_mgr_create_title : loc.user_mgr_edit_title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name_ctrl,
                  decoration: InputDecoration(labelText: loc.user_mgr_name)
                ),
                TextField(
                  controller: email_ctrl,
                  decoration: InputDecoration(labelText: loc.user_mgr_email)
                ),
                TextField(
                  controller: pass_ctrl,
                  decoration: InputDecoration(
                    labelText: usuario == null ? loc.user_mgr_pass : loc.user_mgr_new_pass
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(loc.user_mgr_roles, style: const TextStyle(fontWeight: FontWeight.bold))
                ),
                ...roles_disponibles.map((rol) => CheckboxListTile(
                  title: Text(rol),
                  value: roles_seleccionados.contains(rol),
                  onChanged: (val) => set_state(() {
                    if (val == true) {
                      roles_seleccionados.add(rol);
                    } else {
                      roles_seleccionados.remove(rol);
                    }
                  }),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.user_mgr_cancel)
            ),
            ElevatedButton(
              onPressed: () async {
                if (name_ctrl.text.isEmpty || email_ctrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.user_mgr_err_name_email))
                  );
                  return;
                }
                if (roles_seleccionados.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.user_mgr_err_roles))
                  );
                  return;
                }
                try {
                  final auth = Provider.of<auth_provider>(context, listen: false);
                  if (usuario == null) {
                    if (pass_ctrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.user_mgr_err_pass))
                      );
                      return;
                    }
                    await service_instancia.create_user(
                      user_id:      auth.user_id ?? 1,
                      current_role: 'admin',
                      name:         name_ctrl.text,
                      email:        email_ctrl.text,
                      password:     pass_ctrl.text,
                      roles:        roles_seleccionados,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.user_mgr_msg_created), backgroundColor: Colors.green)
                    );
                  }  else {
                    await service_instancia.update_user(
                      usuario_id:   usuario.user_id,
                      user_id:      auth.user_id ?? 1,
                      current_role: 'admin',
                      name:         name_ctrl.text, 
                      email:        email_ctrl.text, 
                      roles:        roles_seleccionados,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.user_mgr_msg_updated), backgroundColor: Colors.green)
                      );
                    }
                  }
                  Navigator.pop(ctx);
                  _cargar_usuarios();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
                  );
                }
              },
              child: Text(usuario == null ? loc.user_mgr_create_btn : loc.user_mgr_save_btn),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.user_mgr_title),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrir_formulario(loc),
        child: const Icon(Icons.add),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _cargar_usuarios,
            child: ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final user = _usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: user.user_active ? Colors.green : Colors.grey
                    ),
                    title: Text(user.user_name),
                    subtitle: Text(user.user_email),
                    trailing: Wrap(
                      spacing: 4,
                      children: user.roles.map((r) => Chip(
                        label: Text(r, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                      )).toList(),
                    ),
                    onTap: () => _abrir_formulario(loc, usuario: user),
                  ),
                );
              },
            ),
          ),
    );
  }
}