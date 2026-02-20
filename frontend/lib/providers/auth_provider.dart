import 'package:flutter/material.dart';

// gestiona la sesion y el rol del usuario en toda la app
class auth_provider extends ChangeNotifier {
  int? _user_id;
  String? _current_role;
  List<String> _available_roles = [];

  int? get user_id => _user_id;
  String? get current_role => _current_role;
  List<String> get available_roles => _available_roles;

  // guarda los datos al iniciar sesion
  //aqui se cambia lo del usuario admin y los roles para que nos salgan todos los paneles
  void set_user(int id, List<String> roles) {
    _user_id = id;
    _available_roles = roles;
    if (roles.length == 1) _current_role = roles[0];
    notifyListeners();
  }

  // cambia el rol activo desde el selector
  void set_role(String role) {
    _current_role = role;
    notifyListeners();
  }

  // limpia la sesion al salir
  void logout() {
    _user_id = null;
    _current_role = null;
    _available_roles = [];
    notifyListeners();
  }
}