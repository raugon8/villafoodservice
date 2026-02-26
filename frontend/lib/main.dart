import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/screens_auth/login_screen.dart';
import 'screens/screens_home/home_screen.dart';
import 'screens/screens_auth/role_selector_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/user_management_screen.dart';

void main() {
  runApp(
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
      theme: app_theme.light_theme,
      initialRoute: '/login',
      routes: {
        '/login':           (context) => const login_screen(),
        '/':                (context) => const home_screen(),
        '/role_selector':   (context) => const role_selector_screen(),
        '/admin/dashboard': (context) => const dashboard_screen(),
        '/admin/users':     (context) => const user_management_screen(),
      },
    );
  }
}