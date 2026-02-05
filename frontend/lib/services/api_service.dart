import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class api_service {
  static const String base_url = 'http://localhost:8000';

  // registro de usuario
  Future<user> register(String nombre, String email, String password) async {
    final response = await http.post(
      Uri.parse('$base_url/auth/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'nombre_usuario': nombre, 'correo': email, 'contraseña': password}),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // El backend devuelve usuario_ID (mayúscula), lo convertimos a minúscula
      return user(
        usuario_id: data['usuario_ID'],
        nombre_usuario: data['nombre_usuario'],
        correo: data['correo']
      );
    }
    
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Error en el registro');
  }

  // inicio de sesion
  Future<user> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$base_url/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'correo': email, 'contraseña': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // El backend devuelve usuario_ID (mayúscula), lo convertimos a minúscula
      return user(
        usuario_id: data['usuario_ID'],
        nombre_usuario: data['nombre_usuario'],
        correo: data['correo']
      );
    }
    
    final error_data = jsonDecode(response.body);
    throw Exception(error_data['detail'] ?? 'Error al iniciar sesión');
  }
}