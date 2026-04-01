import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class locale_provider extends ChangeNotifier {
  Locale _locale = const Locale('es'); // Español por defecto

  Locale get locale => _locale;

  locale_provider() {
    _load_locale();
  }

  // Carga el idioma guardado de sesiones anteriores
  Future<void> _load_locale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'es';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // Alterna entre Español e Inglés y lo guarda
  Future<void> toggle_locale() async {
    final prefs = await SharedPreferences.getInstance();
    if (_locale.languageCode == 'es') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('es');
    }
    await prefs.setString('language_code', _locale.languageCode);
    notifyListeners();
  }
}