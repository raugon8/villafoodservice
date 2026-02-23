import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; // import subiendo dos niveles
import '../screens_home/home_screen.dart'; // import a la misma altura

class role_selector_screen extends StatelessWidget {
  const role_selector_screen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<auth_provider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('selecciona tu rol')),
      body: ListView.builder(
        itemCount: auth.available_roles.length,
        itemBuilder: (context, index) {
          final role = auth.available_roles[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.person_pin),
              title: Text(role.toUpperCase()),
              onTap: () {
                auth.set_role(role); // asigna el rol elegido al estado global
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const home_screen()));
              },
            ),
          );
        },
      ),
    );
  }
}