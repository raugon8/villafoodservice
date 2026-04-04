import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// gestiona el tamaño del texto guardando la preferencia del usuario
class text_scale_provider extends ChangeNotifier {
  bool _is_large = false;
  
  bool get is_large => _is_large;
  // devuelve 1.4 si esta activo o 1.0 si es normal
  double get scale_factor => _is_large ? 1.4 : 1.0;

  text_scale_provider() {
    _load_preference();
  }

  // carga el valor guardado en el dispositivo al iniciar
  Future<void> _load_preference() async {
    final prefs = await SharedPreferences.getInstance();
    _is_large = prefs.getBool('large_text') ?? false;
    notifyListeners();
  }

  // alterna el tamaño y lo guarda en la memoria del movil
  Future<void> toggle_scale() async {
    _is_large = !_is_large;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('large_text', _is_large);
    notifyListeners();
  }
}