import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/screens_home/home_screen.dart';

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
      theme: app_theme.light_theme, // Aplica el tema aquí
      home: const home_screen(),
    );
  }
}