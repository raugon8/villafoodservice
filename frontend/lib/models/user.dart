// clase 
class user {
  final int usuario_id;
  final String nombre_usuario;
  final String correo;

  user({required this.usuario_id, required this.nombre_usuario, required this.correo});

  // crea objeto desde json del servidor
  factory user.from_json(Map<String, dynamic> json) {
    return user(
      usuario_id: json['usuario_id'], 
      nombre_usuario: json['nombre_usuario'],
      correo: json['correo'],
    );
  }
}