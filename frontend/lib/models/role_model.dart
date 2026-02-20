// modelo de usuario para el panel de administracion
class user_with_roles {
  final int user_id;
  final String user_name;
  final String user_email;
  final List<String> roles;
  final bool user_active;

  user_with_roles({
    required this.user_id, 
    required this.user_name, 
    required this.user_email, 
    required this.roles, 
    required this.user_active
  });
}