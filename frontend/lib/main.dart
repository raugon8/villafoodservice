import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'providers/auth_provider.dart'; 
import 'screens/screens_home/home_screen.dart'; 
import 'screens/screens_auth/role_selector_screen.dart'; 
import 'screens/admin/dashboard_screen.dart'; 

void main() {
  runApp(
    // el multiprovider permite que el rol sea accesible desde cualquier pantalla
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth_provider()),
      ],
      child: const mi_app(),
    ),
  );
}

class mi_app extends StatelessWidget {
  const mi_app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'villafood service',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // definimos las rutas para que la navegacion sea limpia
      initialRoute: '/',
      routes: {
        '/': (context) => const home_screen(),
        '/role_selector': (context) => const role_selector_screen(),
        '/admin/dashboard': (context) => const dashboard_screen(),
      },
    );
  }
}