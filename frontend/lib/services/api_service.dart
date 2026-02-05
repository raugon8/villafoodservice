import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class api_service {
  static const String base_url = 'http://localhost:8000';

  // registro de usuario
  Future<user> register(String nombre, String email, String password) async {
    // --- simulación activa ---
    await Future.delayed(const Duration(seconds: 1));
    return user(usuario_id: 101, nombre_usuario: nombre, correo: email);
    
    /* // --- codigo real ---
    final response = await http.post(
      Uri.parse('$base_url/auth/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'nombre_usuario': nombre, 'correo': email, 'contraseña': password}),
    );
    if (response.statusCode == 201) return user.from_json(jsonDecode(response.body));
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error');
    */
  }

  // inicio de sesion
  Future<user> login(String email, String password) async {
    // --- simulación activa ---
    await Future.delayed(const Duration(seconds: 1));
    if (password == '1234') { // contraseña de prueba
      return user(usuario_id: 202, nombre_usuario: 'andres simulation', correo: email);
    }
    throw Exception('contraseña incorrecta');

    /* // --- código real ---
    final response = await http.post(
      Uri.parse('$base_url/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'correo': email, 'contraseña': password}),
    );
    if (response.statusCode == 200) return user.from_json(jsonDecode(response.body));
    final error_data = jsonDecode(response.body);
    throw Exception(error_data['detail'] ?? 'error al loguear');
    */
  }
}