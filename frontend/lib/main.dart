import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/text_scale_provider.dart';
import 'providers/auth_provider.dart'; 
import 'screens/screens_auth/login_screen.dart'; 
import 'theme/app_theme.dart';

// punto de entrada principal
void main() async {
  // asegura que los widgets nativos esten listos
  WidgetsFlutterBinding.ensureInitialized();

  // inicializa supabase en modo seguro para que no pete si no hay credenciales
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://mock.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'mock_key'),
    );
  } catch (e) {
    debugPrint('supabase modo simulacro');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => text_scale_provider()),
        ChangeNotifierProvider(create: (_) => auth_provider()), 
      ],
      child: const my_app(),
    ),
  );
}

// configuracion raiz de la aplicacion
class my_app extends StatelessWidget {
  const my_app({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<text_scale_provider>(
      builder: (context, text_provider, child) {
        return MaterialApp(
          title: 'villafood',
          debugShowCheckedModeBanner: false, 
          theme: app_theme.theme, 
          builder: (context, widget) {
            // aplicamos el factor de escala a toda la app
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(text_provider.scale_factor),
              ),
              child: widget!,
            );
          },
          home: const login_screen(), 
        );
      },
    );
  }
}