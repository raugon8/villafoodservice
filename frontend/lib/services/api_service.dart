import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/alergeno_model.dart'; // importamos el nuevo modelo

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

  // simula la respuesta del backend para los alergenos europeos (tarea 15 borrarlo cuando lo tenga implementado Raul)
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