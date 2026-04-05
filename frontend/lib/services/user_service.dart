import '../config/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role_model.dart';

// conexion con el backend para la gestion de usuarios
class user_service {
  static const String base_url = AppConstants.apiUrl;

  // lista usuarios requiriendo permisos de admin
  Future<List<user_with_roles>> list_users({int user_id = 1, String current_role = 'admin'}) async {
    final response = await http.get(
      Uri.parse('$base_url/usuarios/?user_id=$user_id&current_role=$current_role&limit=100'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((u) => user_with_roles(
        user_id:     u['user_id'],
        user_name:   u['user_name'],
        user_email:  u['user_email'],
        roles:       List<String>.from(u['roles']),
        user_active: u['user_active'] ?? true,
      )).toList();
    }
    throw Exception('error al cargar usuarios');
  }

  // registra un nuevo usuario asignandole roles iniciales
  Future<user_with_roles> create_user({
    required int user_id,
    required String current_role,
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    final response = await http.post(
      Uri.parse('$base_url/usuarios/?user_id=$user_id&current_role=$current_role'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'usuario_name':     name,
        'usuario_surname':  '', 
        'usuario_email':    email,
        'usuario_password': password,
        'roles':            roles,
      }),
    );
    
    if (response.statusCode == 201) {
      final u = jsonDecode(response.body);
      return user_with_roles(
        user_id:     u['user_id'],
        user_name:   u['user_name'],
        user_email:  u['user_email'],
        roles:       List<String>.from(u['roles']),
        user_active: u['user_active'] ?? true,
      );
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'error al crear usuario');
  }

  // actualiza roles y datos basicos (bug resuelto)
  Future<user_with_roles> update_user({
    required int usuario_id,
    required int user_id,
    required String current_role,
    required String name,
    required String email,
    required List<String> roles,
  }) async {
    final response = await http.patch(
      Uri.parse('$base_url/usuarios/$usuario_id?user_id=$user_id&current_role=$current_role'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'usuario_name': name,
        'usuario_email': email,
        'roles': roles
      }),
    );
    
    if (response.statusCode == 200) {
      final u = jsonDecode(response.body);
      return user_with_roles(
        user_id:     u['user_id'],
        user_name:   u['user_name'],
        user_email:  u['user_email'],
        roles:       List<String>.from(u['roles']),
        user_active: u['user_active'] ?? true,
      );
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'error al actualizar usuario');
  }
}

