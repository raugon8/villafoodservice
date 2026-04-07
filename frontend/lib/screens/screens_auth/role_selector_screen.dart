import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../screens_home/home_screen.dart';

class role_selector_screen extends StatelessWidget {
  const role_selector_screen({super.key});

  // Función para devolver un icono específico según el rol
  IconData _getIconForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Icons.admin_panel_settings;
      case 'cliente': return Icons.shopping_bag;
      case 'dependiente': return Icons.storefront;
      case 'almacen': return Icons.inventory_2;
      default: return Icons.person_pin;
    }
  }

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
      body: Center(
        // ConstrainedBox hace que en Web no se estire de lado a lado
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView.builder(
            itemCount: auth.available_roles.length,
            itemBuilder: (context, index) {
              final role = auth.available_roles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: Icon(_getIconForRole(role), size: 32, color: Theme.of(context).primaryColor),
                  title: Text(role.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    auth.set_role(role);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const home_screen()));
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}