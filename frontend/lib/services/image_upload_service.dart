import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// sube imagenes reales al bucket product-images de Supabase Storage
class image_upload_service {
  final _picker = ImagePicker();
  // nombre del bucket publico donde se almacenan las imagenes de productos
  static const String _bucket = 'product-images';

  /// abre la galeria, sube la imagen seleccionada a Supabase y devuelve la URL publica
  Future<String?> upload_image() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,   // limitamos el tamaño para no subir imagenes gigantes
        maxHeight: 1024,
        imageQuality: 85, // compresion moderada para equilibrar calidad y velocidad
      );
      if (image == null) return null;

      // generamos un nombre unico usando timestamp para evitar colisiones
      final String file_name = 'producto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        // en web usamos bytes directamente porque File no esta disponible
        final bytes = await image.readAsBytes();
        await supabase.storage.from(_bucket).uploadBinary(
          file_name,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
      } else {
        // en movil usamos el archivo del sistema
        final file = File(image.path);
        await supabase.storage.from(_bucket).upload(
          file_name,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
      }

      // obtenemos la URL publica permanente del archivo subido
      final String public_url = supabase.storage.from(_bucket).getPublicUrl(file_name);
      return public_url;

    } catch (e) {
      debugPrint('error al subir imagen: $e');
      return null;
    }
  }
}