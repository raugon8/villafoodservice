import 'package:image_picker/image_picker.dart';

// servicio de simulacion para la subida de imagenes
class image_upload_service {
  final _picker = ImagePicker();

  // abre la galeria y simula la subida devolviendo una url de prueba
  Future<String?> upload_image() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      // simulamos tiempo de subida a internet
      await Future.delayed(const Duration(seconds: 2));

      // devolvemos una foto generica de comida para visualizarla en el frontend
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60';
    } catch (e) {
      return null;
    }
  }
}