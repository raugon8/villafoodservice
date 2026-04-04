import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/text_scale_provider.dart';

// boton reutilizable para alternar el tamaño del texto
class text_scale_toggle extends StatelessWidget {
  const text_scale_toggle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<text_scale_provider>(context);
    
    // etiqueta oculta para que talkback lo lea en voz alta
    return Semantics(
      label: 'cambiar tamaño de texto, actual: ${provider.is_large ? "grande" : "normal"}',
      button: true,
      child: IconButton(
        iconSize: 32, // tamaño minimo accesible
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.text_fields,
              color: provider.is_large ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 4),
            const Text('Aa', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        onPressed: () => provider.toggle_scale(),
        tooltip: 'texto grande', // ayuda visual si dejas el dedo pulsado
      ),
    );
  }
}