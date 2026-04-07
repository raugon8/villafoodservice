import 'package:flutter/material.dart';

class auth_provider extends ChangeNotifier {
  int? _user_id;
  String? _current_role = 'cliente'; // Forzado para pruebas
  List<String> _available_roles = ['admin', 'cliente', 'dependiente', 'almacen'];
  String? _access_token; // NUEVO: Guardamos el token criptográfico

  int? get user_id => _user_id;
  String? get current_role => _current_role;
  List<String> get available_roles => _available_roles;
  String? get access_token => _access_token;

  // Actualizado para recibir el token al iniciar sesión
  void set_login_data(int id, List<String> roles, String token) {
    _user_id = id;
    _available_roles = roles;
    _access_token = token;
    if (roles.isNotEmpty) _current_role = roles[0];
    notifyListeners();
  }

  void set_role(String role) {
    _current_role = role;
    notifyListeners();
  }

  void logout() {
    _user_id = null;
    _current_role = null;
    _available_roles = [];
    _access_token = null;
    notifyListeners();
  }
}