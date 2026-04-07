import 'package:flutter/material.dart';
import 'dart:ui';

class theme_provider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get is_dark_mode {
    if (_themeMode == ThemeMode.system) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggle_theme() {
    _themeMode = is_dark_mode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}