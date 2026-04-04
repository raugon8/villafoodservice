import 'order_model.dart';

// gestor estatico del carrito compartido entre pantallas
class cart_manager {
  static final List<cart_item> items = [];

  // añade un producto o incrementa su cantidad si ya existe
  static void add_item(int product_id, String product_name, double product_price) {
    final existing = items.indexWhere((i) => i.product_id == product_id);
    if (existing >= 0) {
      items[existing].quantity++;
    } else {
      items.add(cart_item(
        product_id: product_id,
        product_name: product_name,
        product_price: product_price,
        quantity: 1
      ));
    }
  }

  // vacia todos los elementos del carrito
  static void clear() {
    items.clear();
  }

  // calcula el total de articulos sumando sus cantidades
  static int get total_items => items.fold(0, (sum, i) => sum + i.quantity);
}