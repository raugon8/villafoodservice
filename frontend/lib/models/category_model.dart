// modelo que representa las categorias de los productos
class category_model {
  final int category_id;
  final String category_name;
  final String? category_description;
  final bool category_active;

  category_model({
    required this.category_id, 
    required this.category_name, 
    this.category_description, 
    this.category_active = true
  });

  // mapea los datos del backend al objeto en dart
  factory category_model.from_json(Map<String, dynamic> json) {
    return category_model(
      category_id: json['category_id'],
      category_name: json['category_name'],
      category_description: json['category_description'],
      category_active: json['category_active'] ?? true,
    );
  }
}