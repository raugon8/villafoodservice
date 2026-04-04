// modelo basico de usuario con sus datos principales
class user {
  final int usuario_id;
  final String nombre_usuario;
  final String correo;

  user({required this.usuario_id, required this.nombre_usuario, required this.correo});

  // crea la instancia a partir del map que devuelve el servidor
  factory user.from_json(Map<String, dynamic> json) {
    return user(
      usuario_id: json['usuario_id'], 
      nombre_usuario: json['nombre_usuario'],
      correo: json['correo'],
    );
  }
}