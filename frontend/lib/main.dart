import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/text_scale_provider.dart';
import 'providers/auth_provider.dart'; 
import 'screens/screens_auth/login_screen.dart'; 
import 'theme/app_theme.dart';

void main() async {
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
        ChangeNotifierProvider(create: (_) => locale_provider()), // añadimos el proveedor de idiomas
      ],
      child: const my_app(),
    ),
  );
}

class my_app extends StatelessWidget {
  const my_app({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos tanto el tamaño de texto como el idioma
    return Consumer2<text_scale_provider, locale_provider>(
      builder: (context, text_provider, locale_provider_inst, child) {
        return MaterialApp(
          title: 'villafood',
          debugShowCheckedModeBanner: false, 
          theme: app_theme.theme,
          
          // --- CONFIGURACIÓN DE IDIOMAS (TAREA 17) ---
          locale: locale_provider_inst.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', ''), // Español
            Locale('en', ''), // Inglés
          ],
          // -------------------------------------------

          builder: (context, widget) {
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