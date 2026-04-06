import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../screens_home/home_screen.dart';

class role_selector_screen extends StatelessWidget {
  const role_selector_screen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<auth_provider>(context);
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.role_selector_title),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: auth.available_roles.length,
        itemBuilder: (context, index) {
          final role = auth.available_roles[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.person_pin),
              // Aquí no traducimos el rol en sí, lo dejamos en su nombre de sistema (ADMIN, CLIENTE...)
              title: Text(role.toUpperCase()),
              onTap: () {
                auth.set_role(role);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const home_screen()));
              },
            ),
          );
        },
      ),
    );
  }
}