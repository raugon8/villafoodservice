import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _abrir_formulario({user_with_roles? usuario}) {
    final name_ctrl     = TextEditingController(text: usuario?.user_name ?? '');
    final email_ctrl    = TextEditingController(text: usuario?.user_email ?? '');
    final pass_ctrl     = TextEditingController();
    final List<String> roles_disponibles = ['admin', 'cliente', 'dependiente', 'almacen'];
    List<String> roles_seleccionados = List.from(usuario?.roles ?? ['cliente']);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set_state) => AlertDialog(
          title: Text(usuario == null ? 'Crear usuario' : 'Editar usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name_ctrl,
                  decoration: const InputDecoration(labelText: 'Nombre completo')
                ),
                TextField(
                  controller: email_ctrl,
                  decoration: const InputDecoration(labelText: 'Email')
                ),
                TextField(
                  controller: pass_ctrl,
                  decoration: InputDecoration(
                    labelText: usuario == null ? 'Contraseña' : 'Nueva contraseña (opcional)'
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Roles:', style: TextStyle(fontWeight: FontWeight.bold))
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
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: () async {
                if (name_ctrl.text.isEmpty || email_ctrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre y email son obligatorios'))
                  );
                  return;
                }
                if (roles_seleccionados.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecciona al menos un rol'))
                  );
                  return;
                }
                try {
                  final auth = Provider.of<auth_provider>(context, listen: false);
                  if (usuario == null) {
                    // Crear usuario nuevo
                    if (pass_ctrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La contraseña es obligatoria'))
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
                      const SnackBar(content: Text('Usuario creado correctamente'), backgroundColor: Colors.green)
                    );
                  } else {
                    // Actualizar roles
                    await service_instancia.update_user_roles(
                      usuario_id:   usuario.user_id,
                      user_id:      auth.user_id ?? 1,
                      current_role: 'admin',
                      roles:        roles_seleccionados,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario actualizado'), backgroundColor: Colors.green)
                    );
                  }
                  Navigator.pop(ctx);
                  _cargar_usuarios();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
                  );
                }
              },
              child: Text(usuario == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gestión de usuarios')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrir_formulario(),
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
                    onTap: () => _abrir_formulario(usuario: user),
                  ),
                );
              },
            ),
          ),
    );
  }
}