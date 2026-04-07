import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';

// sube imagenes al bucket product-images de Supabase usando HTTP directo
// usamos http directamente en lugar de supabase_flutter para evitar problemas de sesion
class image_upload_service {
  final _picker = ImagePicker();

  // URL del storage de Supabase y clave publica — se inyectan via --dart-define
  static const String _supabase_url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tvflsjhtybzwbqxciciv.supabase.co',
  );
  static const String _supabase_key = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const String _bucket = 'product-images';

  /// abre la galeria, sube la imagen a Supabase via HTTP y devuelve la URL publica
  Future<String?> upload_image() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;

      // generamos un nombre unico con timestamp
      final String file_name = 'producto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String upload_url = '$_supabase_url/storage/v1/object/$_bucket/$file_name';

      // leemos los bytes de la imagen — funciona igual en web y movil
      final Uint8List bytes = await image.readAsBytes();

      // subimos directamente via HTTP con los headers correctos
      final response = await http.post(
        Uri.parse(upload_url),
        headers: {
          'apikey':        _supabase_key,
          'Authorization': 'Bearer $_supabase_key',
          'Content-Type':  'image/jpeg',
          'x-upsert':      'true',
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // construimos la URL publica del archivo subido
        final String public_url = '$_supabase_url/storage/v1/object/public/$_bucket/$file_name';
        return public_url;
      }

      debugPrint('error subiendo imagen: ${response.statusCode} ${response.body}');
      return null;

    } catch (e) {
      debugPrint('error al subir imagen: $e');
      return null;
    }
  }
}