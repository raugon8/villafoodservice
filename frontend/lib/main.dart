import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/text_scale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
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
        ChangeNotifierProvider(create: (_) => locale_provider()),
        // tema claro/oscuro añadido por Andrés
        ChangeNotifierProvider(create: (_) => theme_provider()),
      ],
      child: const my_app(),
    ),
  );
}

class my_app extends StatelessWidget {
  const my_app({super.key});

  @override
  Widget build(BuildContext context) {
    // escuchamos texto, idioma y tema
    return Consumer3<text_scale_provider, locale_provider, theme_provider>(
      builder: (context, text_provider, locale_provider_inst, theme_prov, child) {
        return MaterialApp(
          title: 'villafood',
          debugShowCheckedModeBanner: false,
          // soporte de modo claro y oscuro
          theme:      app_theme.lightTheme,
          darkTheme:  app_theme.darkTheme,
          themeMode:  theme_prov.themeMode,
          locale: locale_provider_inst.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', ''),
            Locale('en', ''),
          ],
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