import 'package:flutter/material.dart';
import '../../services/user_service.dart'; // importamos el servicio
import '../../models/role_model.dart'; // importamos el modelo

class user_management_screen extends StatefulWidget {
  const user_management_screen({super.key});
  @override
  State<user_management_screen> createState() => _user_management_screen_state();
}

class _user_management_screen_state extends State<user_management_screen> {
  final service_instancia = user_service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gestion de usuarios')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('simulacion: crear usuario'))),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<user_with_roles>>(
        future: service_instancia.list_users(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.person, color: user.user_active ? Colors.green : Colors.grey),
                  title: Text(user.user_name),
                  subtitle: Text(user.user_email),
                  trailing: Chip(label: Text(user.roles.join(', '))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}