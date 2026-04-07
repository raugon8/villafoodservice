import 'package:flutter/material.dart';

class auth_provider extends ChangeNotifier {
  int? _user_id;
  String? _current_role = 'cliente';
  List<String> _available_roles = ['admin', 'cliente', 'dependiente', 'almacen'];
  // token JWT recibido al hacer login — se inyecta en el header de cada peticion
  String? _token;

  int? get user_id => _user_id;
  String? get current_role => _current_role;
  List<String> get available_roles => _available_roles;
  String? get token => _token;

  void set_user(int id, List<String> roles, {String? token}) {
    _user_id = id;
    _available_roles = roles;
    _token = token;
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
    _token = null;
    notifyListeners();
  }
}