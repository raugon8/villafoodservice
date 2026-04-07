import '../config/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/alergeno_model.dart';

// gestiona la autenticacion principal y recuperacion de roles
class api_service {
  static const String base_url = AppConstants.apiUrl;

  // Helper para generar cabeceras con JWT
  Map<String, String> _headers(String? token) {
    if (token != null && token.isNotEmpty) {
      return {'content-type': 'application/json', 'Authorization': 'Bearer $token'};
    }
    return {'content-type': 'application/json'};
  }

  // registra un nuevo cliente en el backend
  Future<user> register(String nombre, String email, String password) async {
    final response = await http.post(
      Uri.parse('$base_url/auth/register'),
      headers: _headers(null),
      body: jsonEncode({'nombre_usuario': nombre, 'correo': email, 'contraseña': password}),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return user(
        usuario_id:     data['usuario_id'],
        nombre_usuario: data['nombre_usuario'],
        correo:         data['correo']
      );
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error en el registro');
  }

  // MODIFICADO: valida credenciales y devuelve datos completos (usuario + token + roles)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$base_url/auth/login'),
      headers: _headers(null),
      body: jsonEncode({'correo': email, 'contraseña': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usuario = user(
        usuario_id:     data['usuario_id'],
        nombre_usuario: data['nombre_usuario'],
        correo:         data['correo']
      );
      return {
        'user': usuario,
        'token': data['access_token'],
        'roles': List<String>.from(data['roles'] ?? ['cliente'])
      };
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error al iniciar sesion');
  }

  // MODIFICADO: usa el token en la cabecera en lugar de la URL
  Future<List<String>> get_user_roles(int user_id, String token) async {
    final response = await http.get(
      Uri.parse('$base_url/usuarios/me/roles'), // Ya no pasamos ?user_id=X
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['roles']);
    }
    throw Exception('error al obtener roles');
  }

  // llama al endpoint real de alérgenos del backend
  Future<List<alergeno>> get_alergenos() async {
    final response = await http.get(Uri.parse('$base_url/alergenos/'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((a) => alergeno.from_json(a)).toList();
    }
    throw Exception('error al cargar alérgenos');
  }

  // mock obsoleto — se puede borrar cuando se confirme que get_alergenos() funciona
  Future<List<alergeno>> get_alergenos_mock() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      alergeno(id: 1, nombre: 'gluten'),
      alergeno(id: 2, nombre: 'crustaceos'),
      alergeno(id: 3, nombre: 'huevo'),
      alergeno(id: 4, nombre: 'pescado'),
      alergeno(id: 5, nombre: 'cacahuetes'),
      alergeno(id: 6, nombre: 'soja'),
      alergeno(id: 7, nombre: 'lacteos'),
      alergeno(id: 8, nombre: 'frutos de cascara'),
      alergeno(id: 9, nombre: 'apio'),
      alergeno(id: 10, nombre: 'mostaza'),
      alergeno(id: 11, nombre: 'sesamo'),
      alergeno(id: 12, nombre: 'dioxido de azufre y sulfitos'),
      alergeno(id: 13, nombre: 'altramuces'),
      alergeno(id: 14, nombre: 'moluscos'),
    ];
  }
}