import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

// gestiona la autenticacion principal y recuperacion de roles
class api_service {
  static const String base_url = 'http://localhost:8000';

  // registra un nuevo cliente en el backend
  Future<user> register(String nombre, String email, String password) async {
    final response = await http.post(
      Uri.parse('$base_url/auth/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'nombre_usuario': nombre, 'correo': email, 'contraseña': password}),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return user(
        usuario_id:     data['usuario_ID'],
        nombre_usuario: data['nombre_usuario'],
        correo:         data['correo']
      );
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error en el registro');
  }

  // valida credenciales y devuelve el usuario
  Future<user> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$base_url/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'correo': email, 'contraseña': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return user(
        usuario_id:     data['usuario_ID'],
        nombre_usuario: data['nombre_usuario'],
        correo:         data['correo']
      );
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error al iniciar sesion');
  }

  // pide al backend los roles asignados al usuario autenticado
  Future<List<String>> get_user_roles(int user_id) async {
    final response = await http.get(
      Uri.parse('$base_url/usuarios/me/roles?user_id=$user_id'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['roles']);
    }
    throw Exception('error al obtener roles');
  }
}