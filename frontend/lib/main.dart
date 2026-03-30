import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/text_scale_provider.dart';
import 'providers/auth_provider.dart'; 
import 'screens/screens_auth/login_screen.dart'; 
import 'theme/app_theme.dart';


// punto de entrada principal
void main() {
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
          theme: app_theme.theme, // inyectamos la nueva paleta de colores
          builder: (context, widget) {
            // aplicamos el factor de escala a toda la app de golpe
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