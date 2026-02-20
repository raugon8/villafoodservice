import '../models/role_model.dart';

class user_service {
  // simulacion de lista de usuarios
  Future<List<user_with_roles>> list_users() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      user_with_roles(user_id: 1, user_name: 'root admin', user_email: 'root@villafood.com', roles: ['admin'], user_active: true),
    ];
  }
}