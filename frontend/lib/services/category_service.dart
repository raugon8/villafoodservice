import '../models/category_model.dart';

class category_service {
  // simulacion de lista de categorias
  Future<List<category_model>> list_categories({bool active_only = true}) async {
    // Aqui ira el GET 
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      category_model(category_id: 1, category_name: 'Bebidas'),
      category_model(category_id: 2, category_name: 'Pizzas'),
    ];
  }
}